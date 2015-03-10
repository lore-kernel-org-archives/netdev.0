From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next] mpls: Allow mpls_gso and mpls_router to be built as modules
Date: Tue, 10 Mar 2015 16:37:59 +0000
Message-ID: <1426005479-21806-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:48151 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753134AbbCJQiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 12:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_MPLS=m doesn't result in a kernel module being built because it
applies to the net/mpls directory, rather than to .o files.

So revert the MPLS menuitem to being a boolean and make MPLS_GSO and
MPLS_ROUTING tristates to allow mpls_gso and mpls_router modules to be
produced as desired.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/Kconfig  | 6 +++---
 net/mpls/Makefile | 4 +++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index f4286ee..060976d 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -3,7 +3,7 @@
 #
 
 menuconfig MPLS
-	tristate "MultiProtocol Label Switching"
+	bool "MultiProtocol Label Switching"
 	default n
 	---help---
 	  MultiProtocol Label Switching routes packets through logical
@@ -16,14 +16,14 @@ menuconfig MPLS
 if MPLS
 
 config NET_MPLS_GSO
-	bool "MPLS: GSO support"
+	tristate "MPLS: GSO support"
 	help
 	 This is helper module to allow segmentation of non-MPLS GSO packets
 	 that have had MPLS stack entries pushed onto them and thus
 	 become MPLS GSO packets.
 
 config MPLS_ROUTING
-	bool "MPLS: routing support"
+	tristate "MPLS: routing support"
 	help
 	 Add support for forwarding of mpls packets.
 
diff --git a/net/mpls/Makefile b/net/mpls/Makefile
index 60af15f1..65bbe68 100644
--- a/net/mpls/Makefile
+++ b/net/mpls/Makefile
@@ -2,4 +2,6 @@
 # Makefile for MPLS.
 #
 obj-$(CONFIG_NET_MPLS_GSO) += mpls_gso.o
-obj-$(CONFIG_MPLS_ROUTING) += af_mpls.o
+obj-$(CONFIG_MPLS_ROUTING) += mpls_router.o
+
+mpls_router-y := af_mpls.o
-- 
2.1.4
