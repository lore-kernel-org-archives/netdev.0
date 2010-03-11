From: akpm@linux-foundation.org
Subject: [patch 1/5] phonet: use for_each_set_bit()
Date: Thu, 11 Mar 2010 14:07:49 -0800
Message-ID: <201003112207.o2BM7nQn013486@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	akinobu.mita@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47230 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758275Ab0CKWHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:07:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>

Replace open-coded loop with for_each_set_bit().

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/phonet/pn_dev.c     |    3 +--
 net/phonet/pn_netlink.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff -puN net/phonet/pn_dev.c~phonet-use-for_each_set_bit net/phonet/pn_dev.c
--- a/net/phonet/pn_dev.c~phonet-use-for_each_set_bit
+++ a/net/phonet/pn_dev.c
@@ -107,8 +107,7 @@ static void phonet_device_destroy(struct
 	if (pnd) {
 		u8 addr;
 
-		for (addr = find_first_bit(pnd->addrs, 64); addr < 64;
-			addr = find_next_bit(pnd->addrs, 64, 1+addr))
+		for_each_set_bit(addr, pnd->addrs, 64)
 			phonet_address_notify(RTM_DELADDR, dev, addr);
 		kfree(pnd);
 	}
diff -puN net/phonet/pn_netlink.c~phonet-use-for_each_set_bit net/phonet/pn_netlink.c
--- a/net/phonet/pn_netlink.c~phonet-use-for_each_set_bit
+++ a/net/phonet/pn_netlink.c
@@ -141,8 +141,7 @@ static int getaddr_dumpit(struct sk_buff
 			continue;
 
 		addr_idx = 0;
-		for (addr = find_first_bit(pnd->addrs, 64); addr < 64;
-			addr = find_next_bit(pnd->addrs, 64, 1+addr)) {
+		for_each_set_bit(addr, pnd->addrs, 64) {
 			if (addr_idx++ < addr_start_idx)
 				continue;
 
_
