From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 hard-freezes the system on big network loads
Date: Tue, 23 Aug 2011 15:17:26 +0200
Message-ID: <20110823131726.GA21092@electric-eye.fr.zoreil.com>
References: <201108141308.28140.kjun-chen@sambodha.org> <20110821123311.GA20605@electric-eye.fr.zoreil.com> <201108211520.50400.brade@informatik.uni-muenchen.de> <20110821221140.GA20696@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Michael Brade <brade@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33848 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab1HWNfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 09:35:21 -0400
Content-Disposition: inline
In-Reply-To: <20110821221140.GA20696@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> Yes. There is enough data for me to reproduce the bug with the
> exact same chipset.

I can not generate a single rx error and the driver refuses to crash :o/ 

Can you apply the patch below on top of 3.1.0-rc3 and see if it makes
a difference ?

Thanks.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 02339b3..c54ed17 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -5326,10 +5326,6 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				dev->stats.rx_length_errors++;
 			if (status & RxCRC)
 				dev->stats.rx_crc_errors++;
-			if (status & RxFOVF) {
-				rtl8169_schedule_work(dev, rtl8169_reset_task);
-				dev->stats.rx_fifo_errors++;
-			}
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
 		} else {
 			struct sk_buff *skb;
