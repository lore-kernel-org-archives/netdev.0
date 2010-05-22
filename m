From: Dan Carpenter <error27@gmail.com>
Subject: [patch] ipmr: off by one in __ipmr_fill_mroute()
Date: Sat, 22 May 2010 19:54:48 +0200
Message-ID: <20100522175357.GF22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"kernel-janitors@vger.kernel.org David S. Miller"
	<davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:59468 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab0EVRz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 13:55:29 -0400
Received: by qyk13 with SMTP id 13so3358633qyk.1
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 10:55:28 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a smatch warning:
	net/ipv4/ipmr.c +1917 __ipmr_fill_mroute(12) error: buffer overflow
	'(mrt)->vif_table' 32 <= 32

The ipv6 version had the same issue.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 4588910..856123f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1911,7 +1911,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	struct rtattr *mp_head;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
-	if (c->mfc_parent > MAXVIFS)
+	if (c->mfc_parent >= MAXVIFS)
 		return -ENOENT;
 
 	if (VIF_EXISTS(mrt, c->mfc_parent))
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index bd9e7d3..073071f 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2017,7 +2017,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	struct rtattr *mp_head;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
-	if (c->mf6c_parent > MAXMIFS)
+	if (c->mf6c_parent >= MAXMIFS)
 		return -ENOENT;
 
 	if (MIF_EXISTS(mrt, c->mf6c_parent))
