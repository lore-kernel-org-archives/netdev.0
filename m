From: Junchang Wang <junchangwang@gmail.com>
Subject: [PATCH] pktgen: correct uninitialized queue_map
Date: Mon, 8 Nov 2010 17:19:43 +0800
Message-ID: <20101108091941.GB5025@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, robert.olsson@its.uu.se,
	eric.dumazet@gmail.com, joe@perches.com, andy.shevchenko@gmail.com,
	backyes@mail.ustc.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:63219 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228Ab0KHJT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 04:19:56 -0500
Received: by pzk28 with SMTP id 28so793312pzk.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 01:19:56 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This fix a bug reported by backyes.
Right the first time pktgen's using queue_map that's not been initialized
by set_cur_queue_map(pkt_dev);

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
Signed-off-by: Backyes <backyes@mail.ustc.edu.cn>
---

 net/core/pktgen.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2c0df0f..564d9ba 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2611,8 +2611,8 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
-	queue_map = pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
+	queue_map = pkt_dev->cur_queue_map;
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
 
@@ -2975,8 +2975,8 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
-	queue_map = pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
+	queue_map = pkt_dev->cur_queue_map;
 
 	skb = __netdev_alloc_skb(odev,
 				 pkt_dev->cur_pkt_size + 64
--

--Junchang
