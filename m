From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] xen-netback: fix fragments error handling in checksum_setup_ip()
Date: Mon, 16 Dec 2013 10:45:05 +0800
Message-ID: <CAPgLHd97T5bVtCEubkNqChBjSoA5V4Cka=ZQUn=JoYjPCuVE6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
To: ian.campbell@citrix.com, wei.liu2@citrix.com,
	paul.durrant@citrix.com, zoltan.kiss@citrix.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:63360 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab3LPCpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 21:45:07 -0500
Received: by mail-bk0-f49.google.com with SMTP id my13so2080250bkb.8
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 18:45:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -EPROTO error if fragments detected in checksum_setup_ip().

Fixes: 1431fb31ecba ('xen-netback: fix fragment detection in checksum setup')
Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/xen-netback/netback.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 800496b..773b731 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1099,6 +1099,9 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 
 	err = -EPROTO;
 
+	if (fragment)
+		goto out;
+
 	switch (ip_hdr(skb)->protocol) {
 	case IPPROTO_TCP:
 		err = maybe_pull_tail(skb,
