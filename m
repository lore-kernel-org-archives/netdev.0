From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v6 00/12] net-caif: introducing CAIF protocol stack
Date: Mon,  1 Mar 2010 13:12:27 +0100
Message-ID: <1267445559-1911-1-git-send-email-sjur.brandeland@stericsson.com>
Cc: daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gktv.no ([80.239.85.213]:33746 "EHLO mail.gktv.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295Ab0CAMNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 07:13:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

This patch-set introduces the CAIF protocol Stack.
The "Communication CPU to Application CPU Interface" (CAIF) is a packet based
connection-oriented MUX protocol developed by ST-Ericsson for use with its
modems.

Changes since v5:
- Updated usage of standard types.

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
 Documentation/networking/caif/README         |  110 ++
 drivers/net/Kconfig                          |    2 +
 drivers/net/Makefile                         |    1 +
 drivers/net/caif/Kconfig                     |   24 +
 drivers/net/caif/Makefile                    |   14 +
 drivers/net/caif/caif_serial.c               |  463 +++++++++
 include/linux/caif/caif_socket.h             |  164 +++
 include/linux/caif/if_caif.h                 |   34 +
 include/linux/if_arp.h                       |    1 +
 include/linux/if_ether.h                     |    1 +
 include/linux/socket.h                       |    5 +-
 include/linux/tty.h                          |    4 +-
 include/net/caif/caif_dev.h                  |   91 ++
 include/net/caif/caif_device.h               |   57 +
 include/net/caif/caif_layer.h                |  283 +++++
 include/net/caif/cfcnfg.h                    |  134 +++
 include/net/caif/cfctrl.h                    |  136 +++
 include/net/caif/cffrml.h                    |   17 +
 include/net/caif/cfmuxl.h                    |   22 +
 include/net/caif/cfpkt.h                     |  274 +++++
 include/net/caif/cfserl.h                    |   13 +
 include/net/caif/cfsrvl.h                    |   34 +
 net/Kconfig                                  |    2 +
 net/Makefile                                 |    1 +
 net/caif/Kconfig                             |   48 +
 net/caif/Makefile                            |   27 +
 net/caif/caif_config_util.c                  |   88 ++
 net/caif/caif_dev.c                          |  394 +++++++
 net/caif/caif_socket.c                       | 1431 ++++++++++++++++++++++++++
 net/caif/cfcnfg.c                            |  529 ++++++++++
 net/caif/cfctrl.c                            |  711 +++++++++++++
 net/caif/cfdbgl.c                            |   40 +
 net/caif/cfdgml.c                            |  108 ++
 net/caif/cffrml.c                            |  151 +++
 net/caif/cfmuxl.c                            |  246 +++++
 net/caif/cfpkt_skbuff.c                      |  595 +++++++++++
 net/caif/cfrfml.c                            |  106 ++
 net/caif/cfserl.c                            |  199 ++++
 net/caif/cfsrvl.c                            |  185 ++++
 net/caif/cfutill.c                           |  115 ++
 net/caif/cfveil.c                            |  107 ++
 net/caif/cfvidl.c                            |   65 ++
 net/caif/chnl_net.c                          |  429 ++++++++
 44 files changed, 7670 insertions(+), 3 deletions(-)

