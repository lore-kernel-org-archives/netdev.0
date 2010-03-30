From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 00/12] net-caif: introducing CAIF protocol stack
Date: Wed, 31 Mar 2010 01:56:18 +0200
Message-ID: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648Ab0C3X4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:56:42 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400C9AD6GAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:40 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:40 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

This patch-set introduces the CAIF protocol Stack.
The "Communication CPU to Application CPU Interface" (CAIF) is a packet based
connection-oriented MUX protocol developed by ST-Ericsson for use with its
modems.

Changes since v8:
- Fixed compile errors and warnings for 64-bit x86.
- Compiled and fixed sparse errors and warnings.


OVERVIEW:

* CAIF provides a socket interface which can be used to open virtual AT
  channels, create and configure GPRS Data connections.

* A CAIF Network device is also provided for GPRS access.
  This interface can be managed with RTNL.

* A kernel interface is provided allowing Kernel modules to use CAIF.

* A serial link layer layer implemented as a line discipline is currently 
  implemented. Other link interfaces may be contributed at a later stage.

  RTNL
   !
   !	 +------+   +------+   +------+
   !	+------+!  +------+!  +------+!
   !	! Sock !!  !Kernel!!  ! Net  !!
   !	! API  !+  ! API  !+  ! Dev  !+	  <- CAIF "Client" APIs
   !	+------+   +------!   +------+
   !	   !	      !		 !
   !	   +----------!----------+
   !		   +------+		  <- CAIF Core Protocol Implementation
   +------->	   ! CAIF !
		   ! Core !
		   +------+
	     +--------!--------+
	     !		       !
	  +------+	    +-----+
	  ! ldisc!	    ! ... !	  <- Link Layer (Net Devices)
	  +------+	    +-----+
	     !
	  +------+
	  ! tty	 !
	  +------+

Please see Documentation/networking/CAIF for more documentation.

Based on net-next-2.6



Sjur Braendeland (12):
  net-caif: add CAIF protocol definitions
  net-caif: add CAIF socket and configuration headers
  net-caif: add CAIF core protocol stack header files
  net-caif: add CAIF Link layer device header files
  net-caif: add CAIF core protocol stack
  net-caif: add CAIF generic caif support functions
  net-caif: add CAIF device registration functionality
  net-caif: add CAIF socket implementation
  net-caif: add CAIF netdevice
  net-caif: add CAIF Kconfig and Makefiles
  net-caif: add CAIF documentation
  net-caif-driver: add CAIF serial driver (ldisc)

 Documentation/networking/caif/Linux-CAIF.txt |  212 ++++
 Documentation/networking/caif/README         |  109 ++
 drivers/net/Kconfig                          |    2 +
 drivers/net/Makefile                         |    1 +
 drivers/net/caif/Kconfig                     |   17 +
 drivers/net/caif/Makefile                    |   12 +
 drivers/net/caif/caif_serial.c               |  441 ++++++++
 include/linux/caif/caif_socket.h             |  164 +++
 include/linux/caif/if_caif.h                 |   34 +
 include/linux/if_arp.h                       |    1 +
 include/linux/if_ether.h                     |    1 +
 include/linux/socket.h                       |    5 +-
 include/linux/tty.h                          |    4 +-
 include/net/caif/caif_dev.h                  |   90 ++
 include/net/caif/caif_device.h               |   55 +
 include/net/caif/caif_layer.h                |  283 ++++++
 include/net/caif/cfcnfg.h                    |  133 +++
 include/net/caif/cfctrl.h                    |  138 +++
 include/net/caif/cffrml.h                    |   16 +
 include/net/caif/cfmuxl.h                    |   22 +
 include/net/caif/cfpkt.h                     |  274 +++++
 include/net/caif/cfserl.h                    |   12 +
 include/net/caif/cfsrvl.h                    |   34 +
 net/Kconfig                                  |    2 +
 net/Makefile                                 |    1 +
 net/caif/Kconfig                             |   48 +
 net/caif/Makefile                            |   26 +
 net/caif/caif_config_util.c                  |   87 ++
 net/caif/caif_dev.c                          |  413 ++++++++
 net/caif/caif_socket.c                       | 1391 ++++++++++++++++++++++++++
 net/caif/cfcnfg.c                            |  529 ++++++++++
 net/caif/cfctrl.c                            |  664 ++++++++++++
 net/caif/cfdbgl.c                            |   40 +
 net/caif/cfdgml.c                            |  108 ++
 net/caif/cffrml.c                            |  151 +++
 net/caif/cfmuxl.c                            |  246 +++++
 net/caif/cfpkt_skbuff.c                      |  571 +++++++++++
 net/caif/cfrfml.c                            |  108 ++
 net/caif/cfserl.c                            |  192 ++++
 net/caif/cfsrvl.c                            |  185 ++++
 net/caif/cfutill.c                           |  115 +++
 net/caif/cfveil.c                            |  107 ++
 net/caif/cfvidl.c                            |   65 ++
 net/caif/chnl_net.c                          |  451 +++++++++
 44 files changed, 7557 insertions(+), 3 deletions(-)

