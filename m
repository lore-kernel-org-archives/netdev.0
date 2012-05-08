From: Joe Perches <joe@perches.com>
Subject: [PATCH] etherdev.h: Convert int is_<foo>_ether_addr to bool
Date: Tue, 08 May 2012 09:44:40 -0700
Message-ID: <1336495480.29640.19.camel@joe2Laptop>
References: <1336454744.4328.2.camel@jlt3.sipsolutions.net>
	 <20120508.022647.1186809783650560801.davem@davemloft.net>
	 <1336458936.29640.2.camel@joe2Laptop>
	 <20120508.033120.1272130362698029549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54060 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757234Ab2EHQon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 12:44:43 -0400
In-Reply-To: <20120508.033120.1272130362698029549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the return value explicitly true or false.

Signed-off-by: Joe Perches <joe@perches.com>

---

I grepped through the uses, there are a couple of
tests that store to an int that are unaffected.

There are also a couple of senseless tests of
	is_broadcast_ether_addr() || is_multicast_ether_addr()
in staging that could be improved.

 include/linux/etherdevice.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 8a18358..46a95ef 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -59,7 +59,7 @@ extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
  *
  * Return true if the address is all zeroes.
  */
-static inline int is_zero_ether_addr(const u8 *addr)
+static inline bool is_zero_ether_addr(const u8 *addr)
 {
 	return !(addr[0] | addr[1] | addr[2] | addr[3] | addr[4] | addr[5]);
 }
@@ -71,7 +71,7 @@ static inline int is_zero_ether_addr(const u8 *addr)
  * Return true if the address is a multicast address.
  * By definition the broadcast address is also a multicast address.
  */
-static inline int is_multicast_ether_addr(const u8 *addr)
+static inline bool is_multicast_ether_addr(const u8 *addr)
 {
 	return 0x01 & addr[0];
 }
@@ -82,7 +82,7 @@ static inline int is_multicast_ether_addr(const u8 *addr)
  *
  * Return true if the address is a local address.
  */
-static inline int is_local_ether_addr(const u8 *addr)
+static inline bool is_local_ether_addr(const u8 *addr)
 {
 	return 0x02 & addr[0];
 }
@@ -93,7 +93,7 @@ static inline int is_local_ether_addr(const u8 *addr)
  *
  * Return true if the address is the broadcast address.
  */
-static inline int is_broadcast_ether_addr(const u8 *addr)
+static inline bool is_broadcast_ether_addr(const u8 *addr)
 {
 	return (addr[0] & addr[1] & addr[2] & addr[3] & addr[4] & addr[5]) == 0xff;
 }
@@ -104,7 +104,7 @@ static inline int is_broadcast_ether_addr(const u8 *addr)
  *
  * Return true if the address is a unicast address.
  */
-static inline int is_unicast_ether_addr(const u8 *addr)
+static inline bool is_unicast_ether_addr(const u8 *addr)
 {
 	return !is_multicast_ether_addr(addr);
 }
@@ -118,7 +118,7 @@ static inline int is_unicast_ether_addr(const u8 *addr)
  *
  * Return true if the address is valid.
  */
-static inline int is_valid_ether_addr(const u8 *addr)
+static inline bool is_valid_ether_addr(const u8 *addr)
 {
 	/* FF:FF:FF:FF:FF:FF is a multicast address so we don't need to
 	 * explicitly check for it here. */
