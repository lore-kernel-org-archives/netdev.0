From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next-2.6] etherdevice.h: Add is_unicast_ether_addr function
Date: Thu, 13 Jan 2011 09:14:56 +0100
Message-ID: <1294906496-14950-1-git-send-email-tklauser@distanz.ch>
References: <20110112.234250.10542369.davem@davemloft.net>
Cc: tklauser@distanz.ch
To: David Miller <davem@davemloft.net>, cmetcalf@tilera.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:35640 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713Ab1AMIO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 03:14:58 -0500
In-Reply-To: <20110112.234250.10542369.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From a check for !is_multicast_ether_addr it is not always obvious that
we're checking for a unicast address. So add this helper function to
make those code paths easier to read.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 include/linux/etherdevice.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index bec8b82..ab68f78 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -99,6 +99,17 @@ static inline int is_broadcast_ether_addr(const u8 *addr)
 }
 
 /**
+ * is_unicast_ether_addr - Determine if the Ethernet address is unicast
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Return true if the address is a unicast address.
+ */
+static inline int is_unicast_ether_addr(const u8 *addr)
+{
+	return !is_multicast_ether_addr(addr);
+}
+
+/**
  * is_valid_ether_addr - Determine if the given Ethernet address is valid
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
-- 
1.7.0.4

