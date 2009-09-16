From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [RFC] CAIF Protocol Stack
Date: Wed, 16 Sep 2009 14:30:34 +0200
Message-ID: <61D8D34BB13CFE408D154529C120E07902DF9076@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:54374 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbZIPMac convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 08:30:32 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We are currently working on a patch set in order to introduce the
CAIF protocol in Linux. CAIF (Communication CPU to Application CPU Interface)
is the primary protocol used to communicate between to ST-Ericsson modem and
external host system. 

The host processes can use CAIF to open virtual AT channels, initiate GPRS Data
connections, Video channels and Utility Channels.
The Utility Channels are general purpose pipes between modem and host.

ST-Ericsson modems support a number of Link Layers between modem and host,
currently Uart and Shared Memory are available for Linux.

Architecture:
------------
The Implementation of CAIF is divided into:
* CAIF Devices: Character Device, Net Device and Kernel API.
* CAIF Protocol Implementation
* CAIF Link Layer

In order to configure the devices a set of IOCTLs is used.



  IOCTL                                  
   !                                     
   !     +------+   +------+   +------+                 
   !    +------+!  +------+!  +------+!    
   !    ! Chr  !!  !Kernel!!  ! Net  !!
   !    ! Dev  !+  ! API  !+  ! Dev  !+   <- CAIF Devices
   !    +------+   +------!   +------+           
   !       !          !          !       
   !       +----------!----------+
   !               +------+               <- CAIF Protocol Implementation
   +------->       ! CAIF !                  /dev/caifconfig
                   +------+                  
             +--------!--------+         
             !                 !              
          +------+          +-----+     
          !ShMem !          ! TTY !       <- Link Layer          
          +------+          +-----+           

Any comments welcome.



Files:
-----

 net/caif/Kconfig                                   |   61 +
 net/caif/Makefile                                  |   62 +
 net/caif/caif_chnlif.c                             |  209 ++++
 net/caif/caif_chr.c                                |  392 +++++++
 net/caif/caif_config_util.c                        |  279 +++++
 net/caif/chnl_chr.c                                | 1161 ++++++++++++++++++++
 net/caif/chnl_net.c                                |  338 ++++++
 net/caif/generic/cfcnfg.c                          |  722 ++++++++++++
 net/caif/generic/cfctrl.c                          |  640 +++++++++++
 net/caif/generic/cfdgml.c                          |  119 ++
 net/caif/generic/cffrml.c                          |  144 +++
 net/caif/generic/cflist.c                          |   99 ++
 net/caif/generic/cfloopcfg.c                       |   93 ++
 net/caif/generic/cflooplayer.c                     |  113 ++
 net/caif/generic/cfmsll.c                          |   55 +
 net/caif/generic/cfmuxl.c                          |  270 +++++
 net/caif/generic/cfpkt_skbuff.c                    |  545 +++++++++
 net/caif/generic/cfrfml.c                          |  112 ++
 net/caif/generic/cfserl.c                          |  297 +++++
 net/caif/generic/cfshml.c                          |   67 ++
 net/caif/generic/cfspil.c                          |  245 ++++
 net/caif/generic/cfsrvl.c                          |  177 +++
 net/caif/generic/cfutill.c                         |  115 ++
 net/caif/generic/cfveil.c                          |  118 ++
 net/caif/generic/cfvidl.c                          |   68 ++
 net/caif/generic/fcs.c                             |   58 +

 drivers/net/caif/Kconfig                           |   58 +
 drivers/net/caif/Makefile                          |   29 +
 drivers/net/caif/chnl_tty.c                        |  217 ++++
 drivers/net/caif/phyif_loop.c                      |  418 +++++++
 drivers/net/caif/phyif_ser.c                       |  182 +++
 drivers/net/caif/phyif_shm.c                       |  838 ++++++++++++++
 drivers/net/caif/shm.h                             |   95 ++
 drivers/net/caif/shm_cfgifc.c                      |   63 ++
 drivers/net/caif/shm_mbxifc.c                      |  104 ++
 drivers/net/caif/shm_smbx.c                        |   78 ++

 include/linux/caif/caif_config.h                   |  231 ++++
 include/linux/caif/caif_ioctl.h                    |  106 ++
 include/net/caif/caif_actions.h                    |   81 ++
 include/net/caif/caif_chr.h                        |   46 +
 include/net/caif/caif_config_util.h                |   27 +
 include/net/caif/caif_kernel.h                     |  324 ++++++
 include/net/caif/caif_log.h                        |   57 +
 include/net/caif/generic/caif_layer.h              |  476 ++++++++
 include/net/caif/generic/cfcnfg.h                  |  223 ++++
 include/net/caif/generic/cfctrl.h                  |  139 +++
 include/net/caif/generic/cffrml.h                  |   29 +
 include/net/caif/generic/cfglue.h                  |  387 +++++++
 include/net/caif/generic/cfloopcfg.h               |   28 +
 include/net/caif/generic/cflst.h                   |   27 +
 include/net/caif/generic/cfmsll.h                  |   22 +
 include/net/caif/generic/cfmuxl.h                  |   30 +
 include/net/caif/generic/cfpkt.h                   |  246 +++++
 include/net/caif/generic/cfserl.h                  |   22 +
 include/net/caif/generic/cfshml.h                  |   21 +
 include/net/caif/generic/cfspil.h                  |   80 ++
 include/net/caif/generic/cfsrvl.h                  |   48 +
 include/net/caif/generic/fcs.h                     |   22 +



Regards
Sjur Brandeland
ST-Ericsson
