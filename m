From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] arp: make arp_hdr_len() return unsigned int
Date: Tue, 26 Sep 2017 23:12:28 +0300
Message-ID: <20170926201228.GA31899@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:37487 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935367AbdIZUMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 16:12:32 -0400
Received: by mail-wr0-f196.google.com with SMTP id u48so3099625wrf.4
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 13:12:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Negative ARP header length are not a thing.

Constify arguments while I'm at it.

Space savings:

	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-3 (-3)
	function                        old     new   delta
	arpt_do_table                  1163    1160      -3

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/bonding/bond_main.c |    3 ++-
 include/linux/if_arp.h          |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2491,7 +2491,8 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	struct slave *curr_active_slave, *curr_arp_slave;
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
-	int alen, is_arp = skb->protocol == __cpu_to_be16(ETH_P_ARP);
+	int is_arp = skb->protocol == __cpu_to_be16(ETH_P_ARP);
+	unsigned int alen;
 
 	if (!slave_do_arp_validate(bond, slave)) {
 		if ((slave_do_arp_validate_only(bond) && is_arp) ||
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -31,7 +31,7 @@ static inline struct arphdr *arp_hdr(const struct sk_buff *skb)
 	return (struct arphdr *)skb_network_header(skb);
 }
 
-static inline int arp_hdr_len(struct net_device *dev)
+static inline unsigned int arp_hdr_len(const struct net_device *dev)
 {
 	switch (dev->type) {
 #if IS_ENABLED(CONFIG_FIREWIRE_NET)
