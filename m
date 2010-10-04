From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/2] Revert "ipv4: Make INET_LRO a bool instead of
 tristate."
Date: Mon, 04 Oct 2010 02:37:42 +0100
Message-ID: <1286156262.3916.213.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41014 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750931Ab0JDBhs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 21:37:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit e81963b180ac502fda0326edf059b1e29cdef1a2.

LRO is now deprecated in favour of GRO, and only a few drivers use it,
so it is desirable to build it as a module in distribution kernels.

The original change to prevent building it as a module was made in an
attempt to avoid the case where some dependents are set to y and some
to m, and INET_LRO can be set to m rather than y.  However, the
Kconfig system will reliably set INET_LRO=y in this case.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Dave,

You made the change I want to revert in response to
<http://article.gmane.org/gmane.linux.kernel/825646>.  The real problem
with its configuration is actually that CONFIG_INET is not set but
CONFIG_INET_LRO=m, and the fix is to make CONFIG_PASEMI_MAC depend on
CONFIG_INET.

Ben.

 net/ipv4/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 94e0b51..704a0cf 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -420,7 +420,7 @@ config INET_XFRM_MODE_BEET
 	  If unsure, say Y.
 
 config INET_LRO
-	bool "Large Receive Offload (ipv4/tcp)"
+	tristate "Large Receive Offload (ipv4/tcp)"
 	default y
 	---help---
 	  Support for Large Receive Offload (ipv4/tcp).
-- 
1.7.1


