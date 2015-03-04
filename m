From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 1/7] mpls: Refactor how the mpls module is built
Date: Tue, 03 Mar 2015 19:10:23 -0600
Message-ID: <87pp8ptvnk.fsf_-_@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:36270 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932270AbbCDBN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 20:13:57 -0500
In-Reply-To: <87vbihtvts.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 03 Mar 2015 19:06:39 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This refactoring is needed to allow more than just mpls gso
support to be built into the mpls moddule.

Reviewed-by: Simon Horman <horms@verge.net.au>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/Makefile     |  2 +-
 net/mpls/Kconfig | 18 +++++++++++++++++-
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/Makefile b/net/Makefile
index 38704bdf941a..3995613e5510 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -69,7 +69,7 @@ obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
 obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
 obj-$(CONFIG_VSOCKETS)	+= vmw_vsock/
-obj-$(CONFIG_NET_MPLS_GSO)	+= mpls/
+obj-$(CONFIG_MPLS)		+= mpls/
 obj-$(CONFIG_HSR)		+= hsr/
 ifneq ($(CONFIG_NET_SWITCHDEV),)
 obj-y				+= switchdev/
diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index 37421db88965..a77fbcdd04ee 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -1,9 +1,25 @@
 #
 # MPLS configuration
 #
+
+menuconfig MPLS
+	tristate "MultiProtocol Label Switching"
+	default n
+	---help---
+	  MultiProtocol Label Switching routes packets through logical
+	  circuits.  Originally conceved as a way of routing packets at
+	  hardware speeds (before hardware was capable of routing ipv4 packets),
+	  MPLS remains as simple way of making tunnels.
+
+	  If you have not heard of MPLS you probably want to say N here.
+
+if MPLS
+
 config NET_MPLS_GSO
-	tristate "MPLS: GSO support"
+	bool "MPLS: GSO support"
 	help
 	 This is helper module to allow segmentation of non-MPLS GSO packets
 	 that have had MPLS stack entries pushed onto them and thus
 	 become MPLS GSO packets.
+
+endif # MPLS
-- 
2.2.1
