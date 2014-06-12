From: Zachary <zacharyw09264@gmail.com>
Subject: Very Minor Patch to loopback.c
Date: Thu, 12 Jun 2014 15:53:18 -0400
Message-ID: <CAECMkcNrXmuE4saV2==GrCwjwEUzAaGi+NroP5ZXxrRpqr0AwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:41611 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbaFLTxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 15:53:19 -0400
Received: by mail-vc0-f174.google.com with SMTP id hy4so1330776vcb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 12:53:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Very minor patch to loopback.c that I noticed while comparing the
dummy.c code to loopback.c code (dummy.c was based on loopback.c).  I
did not see a maintainer in MAINTAINERS in my cursory glance, so I
apologize if this is to the wrong place.  I am testing this patch
right now on my laptop and it appears to be working without issues.
It also compiled without warnings.

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index bb96409..f9f88d7 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -22,6 +22,7 @@
  *                                      interface.
  *             Alexey Kuznetsov:       Potential hang under some extreme
  *                                     cases removed.
+ *             Zachary Winnerman:  Extremely minor patch in loopback_xmit
  *
  *             This program is free software; you can redistribute it and/or
  *             modify it under the terms of the GNU General Public License
@@ -72,7 +73,6 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
                                 struct net_device *dev)
 {
        struct pcpu_lstats *lb_stats;
-       int len;

        skb_orphan(skb);

@@ -86,10 +86,9 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
        /* it's OK to use per_cpu_ptr() because BHs are off */
        lb_stats = this_cpu_ptr(dev->lstats);

-       len = skb->len;
        if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
                u64_stats_update_begin(&lb_
stats->syncp);
-               lb_stats->bytes += len;
+               lb_stats->bytes += skb->len;
                lb_stats->packets++;
                u64_stats_update_end(&lb_stats->syncp);
        }
