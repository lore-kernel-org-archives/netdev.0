From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 00/13] net-caif: introducing CAIF protocol stack
Date: Wed, 20 Jan 2010 23:55:17 +0100
Message-ID: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870Ab0ATX4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:18 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00DO0ICJDL70@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:55:31 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:55:31 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set introduces the CAIF protocol Stack.

The "Communication CPU to Application CPU Interface" (CAIF) is a packet based
connection-oriented MUX protocol developed by ST-Ericsson for use with its
modems.

* CAIF provides a socket interface which can be used to open virtual AT
  channels, create and configure GPRS Data connections.

* A CAIF Network device is also provided for GPRS access.
  This interface can be managed with socket IOCTLs or RTNL.

* A kernel interface is provided allowing Kernel modules to use CAIF.

* A serial link layer layer implemented as a line discipline is currently 
  implemented. Other link interfaces may be contributed at a later stage.

  RTNL/IOCTL
   !
   !	 +------+   +------+   +------+
   !	+------+!  +------+!  +------+!
   !	! Sock !!  !Kernel!!  ! Net  !!
   !	! API  !+  ! API  !+  ! Dev  !+	  <- CAIF "Client" APIs
   !	+------+   +------!   +------+
   !	   !	      !		 !
   !	   +----------!----------+
   !		   +------+		  <- CAIF Protocol Implementation
   +------->	   ! CAIF !
		   +------+
	     +--------!--------+
	     !		       !
	  +------+	    +-----+
	  ! ldisc!	    ! ... !	  <- Link Layer (Net Devices)
	  +------+	    +-----+
	     !
	  +------+
	  ! tty	 !			  <- Serial Layer
	  +------+


The patch set is based on net-next-2.6.


Sjur Braendeland (13):
  net-caif: add CAIF protocol definitions
  net-caif: add CAIF header files
  net-caif: add CAIF generic protocol stack header files
  net-caif: add CAIF header files
  net-caif: add CAIF generic protocol stack
  net-caif: add CAIF generic caif support functions
  net-caif: add CAIF device registration functionality
  net-caif: add CAIF socket implementation
  net-caif: add CAIF netdevice
  net-caif: add kernel-client API for CAIF
  net-caif: add CAIF Kconfig and Makefiles
  net-caif: add CAIF documentation
  net-caif-driver: add CAIF serial driver (ldisc)

 Documentation/networking/caif/Linux-CAIF.txt |  235 +++++
 Documentation/networking/caif/README         |   27 +
 drivers/net/Kconfig                          |    2 +
 drivers/net/Makefile                         |    1 +
 drivers/net/caif/Kconfig                     |   15 +
 drivers/net/caif/Makefile                    |   14 +
 drivers/net/caif/caif_serial.c               |  420 ++++++++
 include/linux/caif/caif_config.h             |  155 +++
 include/linux/caif/caif_socket.h             |  161 +++
 include/linux/caif/if_caif.h                 |   71 ++
 include/linux/if_arp.h                       |    1 +
 include/linux/if_ether.h                     |    1 +
 include/linux/socket.h                       |    5 +-
 include/linux/tty.h                          |    4 +-
 include/net/caif/caif_dev.h                  |   29 +
 include/net/caif/caif_device.h               |   34 +
 include/net/caif/caif_kernel.h               |  309 ++++++
 include/net/caif/generic/caif_layer.h        |  225 ++++
 include/net/caif/generic/cfcnfg.h            |  110 ++
 include/net/caif/generic/cfctrl.h            |  136 +++
 include/net/caif/generic/cffrml.h            |   19 +
 include/net/caif/generic/cfglue.h            |  110 ++
 include/net/caif/generic/cflst.h             |   19 +
 include/net/caif/generic/cfmuxl.h            |   22 +
 include/net/caif/generic/cfpkt.h             |  274 +++++
 include/net/caif/generic/cfserl.h            |   14 +
 include/net/caif/generic/cfsrvl.h            |   33 +
 net/Kconfig                                  |    2 +
 net/Makefile                                 |    1 +
 net/caif/Kconfig                             |   57 +
 net/caif/Makefile                            |   29 +
 net/caif/caif_chnlif.c                       |  177 ++++
 net/caif/caif_config_util.c                  |  121 +++
 net/caif/caif_dev.c                          |  417 ++++++++
 net/caif/caif_socket.c                       | 1427 ++++++++++++++++++++++++++
 net/caif/chnl_net.c                          |  566 ++++++++++
 net/caif/generic/cfcnfg.c                    |  538 ++++++++++
 net/caif/generic/cfctrl.c                    |  699 +++++++++++++
 net/caif/generic/cfdgml.c                    |  106 ++
 net/caif/generic/cffrml.c                    |  148 +++
 net/caif/generic/cflist.c                    |   88 ++
 net/caif/generic/cfmuxl.c                    |  225 ++++
 net/caif/generic/cfpkt_skbuff.c              |  596 +++++++++++
 net/caif/generic/cfrfml.c                    |  104 ++
 net/caif/generic/cfserl.c                    |  198 ++++
 net/caif/generic/cfsrvl.c                    |  182 ++++
 net/caif/generic/cfutill.c                   |  112 ++
 net/caif/generic/cfveil.c                    |  106 ++
 net/caif/generic/cfvidl.c                    |   62 ++
 49 files changed, 8404 insertions(+), 3 deletions(-)

