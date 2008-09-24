From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] Phonet: improve documentation
Date: Wed, 24 Sep 2008 15:15:06 +0300
Message-ID: <200809241515.06378.remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com> <1222098445-26175-11-git-send-email-remi.denis-courmont@nokia.com> <20080923144320.fc1fc81c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "ext Randy Dunlap" <randy.dunlap@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:21156 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbYIXMP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 08:15:56 -0400
In-Reply-To: <20080923144320.fc1fc81c.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix grammar errors spotted by Randy Dunlap,
and adds some more details.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 Documentation/networking/phonet.txt |   32 +++++++++++++++++++++-----------
 1 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networking/phonet.txt
index f3c72e0..1506c31 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -21,7 +21,7 @@ depending on the device, such as:
 Packets format
 --------------
 
-Phonet packet have a common header as follow:
+Phonet packets have a common header as follow:
 
   struct phonethdr {
     uint8_t  pn_media;  /* Media type (link-layer identifier) */
@@ -33,14 +33,17 @@ Phonet packet have a common header as follow:
     uint8_t  pn_sobj;   /* Sender object ID */
   };
 
-The device ID is split: the 6 higher order bits consitutes the device
-address, while the 2 lower order bits are used for multiplexing, as are
-the 8-bits object identifiers. As such, Phonet can be considered as a
+On Linux, the link-layer header includes the pn_media byte (see below).
+The next 7 bytes are part of the network-layer header.
+
+The device ID is split: the 6 higher order-bits consitute the device
+address, while the 2 lower-order bits are used for multiplexing, as are
+the 8-bit object identifiers. As such, Phonet can be considered as a
 network layer with 6 bits of address space and 10 bits for transport
 protocol (much like port numbers in IP world).
 
-The modem always has address number zero. Each other device has a its
-own 6-bits address.
+The modem always has address number zero. All other device have a their
+own 6-bit address.
 
 
 Link layer
@@ -49,11 +52,18 @@ Link layer
 Phonet links are always point-to-point links. The link layer header
 consists of a single Phonet media type byte. It uniquely identifies the
 link through which the packet is transmitted, from the modem's
-perspective.
-
-Linux Phonet network interfaces use a dedicated link layer type
-(ETH_P_PHONET) which is out of the Ethernet type range. They can only
-send and receive Phonet packets.
+perspective. Each Phonet network device shall prepend and set the media
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
 
 Note that Phonet interfaces are not allowed to re-order packets, so
 only the (default) Linux FIFO qdisc should be used with them.
-- 
1.5.4.3
