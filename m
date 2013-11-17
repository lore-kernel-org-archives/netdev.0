From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Mon, 18 Nov 2013 00:15:45 +0100
Message-ID: <20131117231545.GA32350@electric-eye.fr.zoreil.com>
References: <8761s0cqhh.fsf@natisbad.org>
 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
 <87y54u59zq.fsf@natisbad.org>
 <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
 <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com>
 <8738n0ngq3.fsf@natisbad.org>
 <pan.2013.11.13.21.59.50.578858@googlemail.com>
 <1384386040.28458.143.camel@edumazet-glaptop2.roam.corp.google.com>
 <pan.2013.11.13.23.52.41.470832@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Holger Hoffstaette <holger.hoffstaette@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36979 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750Ab3KQXPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 18:15:49 -0500
Content-Disposition: inline
In-Reply-To: <pan.2013.11.13.23.52.41.470832@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger Hoffstaette <holger.hoffstaette@googlemail.com> :
[...]
> Since I saw this with r8169->r8169 and e1000e->r8169 it's probably
> everyone's favourite r8169 :)
> Unfortunately I can't be more help but if you can suggest/whip up a fix
> I'd be happy to help test.

The r8169 driver does not rely on a timer for Tx completion.

The patch below should not hurt.

Can you describe your system a bit more specifically ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3397cee..7280d5d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6393,12 +6393,12 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	status = rtl_get_events(tp);
 	rtl_ack_events(tp, status & ~tp->event_slow);
 
-	if (status & RTL_EVENT_NAPI_RX)
-		work_done = rtl_rx(dev, tp, (u32) budget);
-
 	if (status & RTL_EVENT_NAPI_TX)
 		rtl_tx(dev, tp);
 
+	if (status & RTL_EVENT_NAPI_RX)
+		work_done = rtl_rx(dev, tp, (u32) budget);
+
 	if (status & tp->event_slow) {
 		enable_mask &= ~tp->event_slow;
 
