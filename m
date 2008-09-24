From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 2/3] Phonet: improve documentation
Date: Wed, 24 Sep 2008 19:11:39 +0300
Message-ID: <1222272700-28232-2-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:17739 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbYIXQL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 12:11:59 -0400
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8OGBtEc025585
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 19:11:57 +0300
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

=46ix grammar errors spotted by Randy Dunlap,
and adds some more details.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 Documentation/networking/phonet.txt |   32 +++++++++++++++++++++------=
-----
 1 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networ=
king/phonet.txt
index f3c72e0..57d3e59 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -21,7 +21,7 @@ depending on the device, such as:
 Packets format
 --------------
=20
-Phonet packet have a common header as follow:
+Phonet packets have a common header as follows:
=20
   struct phonethdr {
     uint8_t  pn_media;  /* Media type (link-layer identifier) */
@@ -33,14 +33,17 @@ Phonet packet have a common header as follow:
     uint8_t  pn_sobj;   /* Sender object ID */
   };
=20
-The device ID is split: the 6 higher order bits consitutes the device
-address, while the 2 lower order bits are used for multiplexing, as ar=
e
-the 8-bits object identifiers. As such, Phonet can be considered as a
+On Linux, the link-layer header includes the pn_media byte (see below)=
=2E
+The next 7 bytes are part of the network-layer header.
+
+The device ID is split: the 6 higher-order bits consitute the device
+address, while the 2 lower-order bits are used for multiplexing, as ar=
e
+the 8-bit object identifiers. As such, Phonet can be considered as a
 network layer with 6 bits of address space and 10 bits for transport
 protocol (much like port numbers in IP world).
=20
-The modem always has address number zero. Each other device has a its
-own 6-bits address.
+The modem always has address number zero. All other device have a thei=
r
+own 6-bit address.
=20
=20
 Link layer
@@ -49,11 +52,18 @@ Link layer
 Phonet links are always point-to-point links. The link layer header
 consists of a single Phonet media type byte. It uniquely identifies th=
e
 link through which the packet is transmitted, from the modem's
-perspective.
-
-Linux Phonet network interfaces use a dedicated link layer type
-(ETH_P_PHONET) which is out of the Ethernet type range. They can only
-send and receive Phonet packets.
+perspective. Each Phonet network device shall prepend and set the medi=
a
+type byte as appropriate. For convenience, a common phonet_header_ops
+link-layer header operations structure is provided. It sets the
+media type according to the network device hardware address.
+
+Linux Phonet network interfaces support a dedicated link layer packets
+type (ETH_P_PHONET) which is out of the Ethernet type range. They can
+only send and receive Phonet packets.
+
+The virtual TUN tunnel device driver can also be used for Phonet. This
+requires IFF_TUN mode, _without_ the IFF_NO_PI flag. In this case,
+there is no link-layer header, so there is no Phonet media type byte.
=20
 Note that Phonet interfaces are not allowed to re-order packets, so
 only the (default) Linux FIFO qdisc should be used with them.
--=20
1.5.4.3

