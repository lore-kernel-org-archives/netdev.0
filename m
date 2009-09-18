From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [RFC] CAIF Protocol Stack
Date: Fri, 18 Sep 2009 14:01:52 +0200
Message-ID: <61D8D34BB13CFE408D154529C120E07902DF96ED@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:44599 "EHLO
	mailgw3.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbZIRMQw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 08:16:52 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David.

I understand that you are one of the main Maintainers of netdev.
As explained below we have a largeish driver we would like to contribut=
e.
I realize we should have started contributing this on a earlier stage..=
=2E., but
What is the preferred way of doing this, i.e. how should we split it up=
?
   Submit the whole shebang,
Or
   Split Horizontally e.g. a) CAIF-Protocol, b) GPRS-Net-Device c) CAIF=
-Link Layer
Or
   Split Vertically e.g. a) Payload Path Net-Device, b) Payload Path AT=
-channel, c) Configuration

Which kernel GIT should we base the patch set on?

Any hints on this would be greatly appreciated.

Best Regards
Sjur Br=E6ndeland
ST-Ericsson


> -----Original Message-----
> From: Sjur Br=E6ndeland=20
> Sent: 16. september 2009 14:31
> To: 'netdev@vger.kernel.org'
> Subject: [RFC] CAIF Protocol Stack
>=20
> Hello,
>=20
> We are currently working on a patch set in order to introduce=20
> the CAIF protocol in Linux. CAIF (Communication CPU to=20
> Application CPU Interface) is the primary protocol used to=20
> communicate between to ST-Ericsson modem and external host system.=20
>=20
> The host processes can use CAIF to open virtual AT channels,=20
> initiate GPRS Data connections, Video channels and Utility Channels.
> The Utility Channels are general purpose pipes between modem and host=
=2E
>=20
> ST-Ericsson modems support a number of Link Layers between=20
> modem and host, currently Uart and Shared Memory are=20
> available for Linux.
>=20
> Architecture:
> ------------
> The Implementation of CAIF is divided into:
> * CAIF Devices: Character Device, Net Device and Kernel API.
> * CAIF Protocol Implementation
> * CAIF Link Layer
>=20
> In order to configure the devices a set of IOCTLs is used.
>=20
>=20
>=20
>   IOCTL                                 =20
>    !                                    =20
>    !     +------+   +------+   +------+                =20
>    !    +------+!  +------+!  +------+!   =20
>    !    ! Chr  !!  !Kernel!!  ! Net  !!
>    !    ! Dev  !+  ! API  !+  ! Dev  !+   <- CAIF Devices
>    !    +------+   +------!   +------+          =20
>    !       !          !          !      =20
>    !       +----------!----------+
>    !               +------+               <- CAIF Protocol=20
> Implementation
>    +------->       ! CAIF !                  /dev/caifconfig
>                    +------+                 =20
>              +--------!--------+        =20
>              !                 !             =20
>           +------+          +-----+    =20
>           !ShMem !          ! TTY !       <- Link Layer         =20
>           +------+          +-----+          =20
>=20
> Any comments welcome.
>=20
>=20
>=20
> Files:
> -----
>=20
>  net/caif/Kconfig                                   |   61 +
>  net/caif/Makefile                                  |   62 +
>  net/caif/caif_chnlif.c                             |  209 ++++
>  net/caif/caif_chr.c                                |  392 +++++++
>  net/caif/caif_config_util.c                        |  279 +++++
>  net/caif/chnl_chr.c                                | 1161=20
> ++++++++++++++++++++
>  net/caif/chnl_net.c                                |  338 ++++++
>  net/caif/generic/cfcnfg.c                          |  722=20
> ++++++++++++
>  net/caif/generic/cfctrl.c                          |  640 ++++++++++=
+
>  net/caif/generic/cfdgml.c                          |  119 ++
>  net/caif/generic/cffrml.c                          |  144 +++
>  net/caif/generic/cflist.c                          |   99 ++
>  net/caif/generic/cfloopcfg.c                       |   93 ++
>  net/caif/generic/cflooplayer.c                     |  113 ++
>  net/caif/generic/cfmsll.c                          |   55 +
>  net/caif/generic/cfmuxl.c                          |  270 +++++
>  net/caif/generic/cfpkt_skbuff.c                    |  545 +++++++++
>  net/caif/generic/cfrfml.c                          |  112 ++
>  net/caif/generic/cfserl.c                          |  297 +++++
>  net/caif/generic/cfshml.c                          |   67 ++
>  net/caif/generic/cfspil.c                          |  245 ++++
>  net/caif/generic/cfsrvl.c                          |  177 +++
>  net/caif/generic/cfutill.c                         |  115 ++
>  net/caif/generic/cfveil.c                          |  118 ++
>  net/caif/generic/cfvidl.c                          |   68 ++
>  net/caif/generic/fcs.c                             |   58 +
>=20
>  drivers/net/caif/Kconfig                           |   58 +
>  drivers/net/caif/Makefile                          |   29 +
>  drivers/net/caif/chnl_tty.c                        |  217 ++++
>  drivers/net/caif/phyif_loop.c                      |  418 +++++++
>  drivers/net/caif/phyif_ser.c                       |  182 +++
>  drivers/net/caif/phyif_shm.c                       |  838=20
> ++++++++++++++
>  drivers/net/caif/shm.h                             |   95 ++
>  drivers/net/caif/shm_cfgifc.c                      |   63 ++
>  drivers/net/caif/shm_mbxifc.c                      |  104 ++
>  drivers/net/caif/shm_smbx.c                        |   78 ++
>=20
>  include/linux/caif/caif_config.h                   |  231 ++++
>  include/linux/caif/caif_ioctl.h                    |  106 ++
>  include/net/caif/caif_actions.h                    |   81 ++
>  include/net/caif/caif_chr.h                        |   46 +
>  include/net/caif/caif_config_util.h                |   27 +
>  include/net/caif/caif_kernel.h                     |  324 ++++++
>  include/net/caif/caif_log.h                        |   57 +
>  include/net/caif/generic/caif_layer.h              |  476 ++++++++
>  include/net/caif/generic/cfcnfg.h                  |  223 ++++
>  include/net/caif/generic/cfctrl.h                  |  139 +++
>  include/net/caif/generic/cffrml.h                  |   29 +
>  include/net/caif/generic/cfglue.h                  |  387 +++++++
>  include/net/caif/generic/cfloopcfg.h               |   28 +
>  include/net/caif/generic/cflst.h                   |   27 +
>  include/net/caif/generic/cfmsll.h                  |   22 +
>  include/net/caif/generic/cfmuxl.h                  |   30 +
>  include/net/caif/generic/cfpkt.h                   |  246 +++++
>  include/net/caif/generic/cfserl.h                  |   22 +
>  include/net/caif/generic/cfshml.h                  |   21 +
>  include/net/caif/generic/cfspil.h                  |   80 ++
>  include/net/caif/generic/cfsrvl.h                  |   48 +
>  include/net/caif/generic/fcs.h                     |   22 +
>=20
>=20
>=20
> Regards
> Sjur Brandeland
> ST-Ericsson
