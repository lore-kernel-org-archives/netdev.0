From: sjur.brandeland@stericsson.com
Subject: [net-next 08/11] Documentation/networking/caif: Update documentation
Date: Mon, 25 Jun 2012 19:49:40 +0200
Message-ID: <1340646583-21059-9-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?=
	<sjur.brandeland@stericssion.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:58023 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab2FYRuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:50:05 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so6807294lbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:50:05 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Update drawing and remove description of old features.
Add HSI and USB link layers to the drawing.

Reported-by: Joerg Reisenweber <joerg.reisenweber@stericssion.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericssion.com>
---
 Documentation/networking/caif/Linux-CAIF.txt |   91 ++++++++----------=
--------
 1 files changed, 27 insertions(+), 64 deletions(-)

diff --git a/Documentation/networking/caif/Linux-CAIF.txt b/Documentati=
on/networking/caif/Linux-CAIF.txt
index e52fd62..0aa4bd3 100644
--- a/Documentation/networking/caif/Linux-CAIF.txt
+++ b/Documentation/networking/caif/Linux-CAIF.txt
@@ -19,60 +19,36 @@ and host. Currently, UART and Loopback are availabl=
e for Linux.
 Architecture:
 ------------
 The implementation of CAIF is divided into:
-* CAIF Socket Layer, Kernel API, and  Net Device.
+* CAIF Socket Layer and GPRS IP Interface.
 * CAIF Core Protocol Implementation
 * CAIF Link Layer, implemented as NET devices.
=20
=20
   RTNL
    !
-   !	 +------+   +------+   +------+
-   !	+------+!  +------+!  +------+!
-   !	! Sock !!  !Kernel!!  ! Net  !!
-   !	! API  !+  ! API  !+  ! Dev  !+	  <- CAIF Client APIs
-   !	+------+   +------!   +------+
-   !	   !	      !		 !
-   !	   +----------!----------+
-   !		   +------+		  <- CAIF Protocol Implementation
-   +------->	   ! CAIF !
-		   ! Core !
-		   +------+
-	     +--------!--------+
-	     !		       !
-	  +------+	    +-----+
-	  !    	 !	    ! TTY !	  <- Link Layer (Net Devices)
-	  +------+	    +-----+
-
-
-Using the Kernel API
-----------------------
-The Kernel API is used for accessing CAIF channels from the
-kernel.
-The user of the API has to implement two callbacks for receive
-and control.
-The receive callback gives a CAIF packet as a SKB. The control
-callback will
-notify of channel initialization complete, and flow-on/flow-
-off.
-
-
-  struct caif_device caif_dev =3D {
-    .caif_config =3D {
-     .name =3D "MYDEV"
-     .type =3D CAIF_CHTY_AT
-    }
-   .receive_cb =3D my_receive,
-   .control_cb =3D my_control,
-  };
-  caif_add_device(&caif_dev);
-  caif_transmit(&caif_dev, skb);
-
-See the caif_kernel.h for details about the CAIF kernel API.
+   !	      +------+	 +------+
+   !	     +------+!	+------+!
+   !	     !	IP  !!	!Socket!!
+   +-------> !interf!+	! API  !+	<- CAIF Client APIs
+   !	     +------+	+------!
+   !		!	    !
+   !		+-----------+
+   !		      !
+   !		   +------+		<- CAIF Core Protocol
+   !		   ! CAIF !
+   !		   ! Core !
+   !		   +------+
+   !	   +----------!---------+
+   !	   !	      !		!
+   !	+------+   +-----+   +------+
+   +--> ! HSI  !   ! TTY !   ! USB  !	<- Link Layer (Net Devices)
+	+------+   +-----+   +------+
+
=20
=20
 I M P L E M E N T A T I O N
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
+
=20
 CAIF Core Protocol Layer
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
@@ -88,17 +64,13 @@ The Core CAIF implementation contains:
       -	Simple implementation of CAIF.
       -	Layered architecture (a la Streams), each layer in the CAIF
 	specification is implemented in a separate c-file.
-      -	Clients must implement PHY layer to access physical HW
-	with receive and transmit functions.
       -	Clients must call configuration function to add PHY layer.
       -	Clients must implement CAIF layer to consume/produce
 	CAIF payload with receive and transmit functions.
       -	Clients must call configuration function to add and connect th=
e
 	Client layer.
       - When receiving / transmitting CAIF Packets (cfpkt), ownership =
is passed
-	to the called function (except for framing layers' receive functions
-	or if a transmit function returns an error, in which case the caller
-	must free the packet).
+	to the called function (except for framing layers' receive function)
=20
 Layered Architecture
 --------------------
@@ -109,11 +81,6 @@ Implementation. The support functions include:
 	CAIF Packet has functions for creating, destroying and adding content
 	and for adding/extracting header and trailers to protocol packets.
=20
-      - CFLST CAIF list implementation.
-
-      - CFGLUE CAIF Glue. Contains OS Specifics, such as memory
-	allocation, endianness, etc.
-
 The CAIF Protocol implementation contains:
=20
       - CFCNFG CAIF Configuration layer. Configures the CAIF Protocol
@@ -128,7 +95,7 @@ The CAIF Protocol implementation contains:
 	control and remote shutdown requests.
=20
       - CFVEI CAIF VEI layer. Handles CAIF AT Channels on VEI (Virtual
-        External Interface). This layer encodes/decodes VEI frames.
+	External Interface). This layer encodes/decodes VEI frames.
=20
       - CFDGML CAIF Datagram layer. Handles CAIF Datagram layer (IP
 	traffic), encodes/decodes Datagram frames.
@@ -170,7 +137,7 @@ The CAIF Protocol implementation contains:
 	    +---------+	    +---------+
 		 !		!
 	    +---------+	    +---------+
-	    |         |	    | Serial  |
+	    |	      |	    | Serial  |
 	    |	      |	    | CFSERL  |
 	    +---------+	    +---------+
=20
@@ -186,24 +153,20 @@ In this layered approach the following "rules" ap=
ply.
 		 layer->dn->transmit(layer->dn, packet);
=20
=20
-Linux Driver Implementation
+CAIF Socket and IP interface
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
=20
-Linux GPRS Net Device and CAIF socket are implemented on top of the
-CAIF Core protocol. The Net device and CAIF socket have an instance of
+The IP interface and CAIF socket API are implemented on top of the
+CAIF Core protocol. The IP Interface and CAIF socket have an instance =
of
 'struct cflayer', just like the CAIF Core protocol stack.
 Net device and Socket implement the 'receive()' function defined by
 'struct cflayer', just like the rest of the CAIF stack. In this way, t=
ransmit and
 receive of packets is handled as by the rest of the layers: the 'dn->t=
ransmit()'
 function is called in order to transmit data.
=20
-The layer on top of the CAIF Core implementation is
-sometimes referred to as the "Client layer".
-
-
 Configuration of Link Layer
 ---------------------------
-The Link Layer is implemented as Linux net devices (struct net_device)=
=2E
+The Link Layer is implemented as Linux network devices (struct net_dev=
ice).
 Payload handling and registration is done using standard Linux mechani=
sms.
=20
 The CAIF Protocol relies on a loss-less link layer without implementin=
g
--=20
1.7.5.4
