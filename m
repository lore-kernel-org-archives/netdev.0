From: Dan Carpenter <error27@gmail.com>
Subject: [patch] net/llc: storing negative error codes in unsigned short
Date: Thu, 16 Sep 2010 20:12:55 +0200
Message-ID: <20100916181155.GB7867@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:36310 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612Ab0IPSNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 14:13:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the alloc_skb() fails then we return 65431 instead of -ENOBUFS
(-105). 

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index e4dae02..cf4aea3 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -689,7 +689,7 @@ static void llc_station_rcv(struct sk_buff *skb)
 
 int __init llc_station_init(void)
 {
-	u16 rc = -ENOBUFS;
+	int rc = -ENOBUFS;
 	struct sk_buff *skb;
 	struct llc_station_state_ev *ev;
 
