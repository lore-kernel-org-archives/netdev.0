From: David Miller <davem@davemloft.net>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Fri, 28 Mar 2008 18:36:52 -0700 (PDT)
Message-ID: <20080328.183652.99818676.davem@davemloft.net>
References: <47C92F49.4070100@cosmosbay.com>
	<20080323.032949.194309002.davem@davemloft.net>
	<47E6A5FD.6060407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57361
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750850AbYC2Bgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 21:36:52 -0400
In-Reply-To: <47E6A5FD.6060407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 23 Mar 2008 19:48:29 +0100

> [PATCH] loopback: calls netif_receive_skb() instead of netif_rx()

Hmmm...

+static int enough_stack_space(void)
+{
+#ifdef CONFIG_STACK_GROWSUP
+	return 0;
+#else
+	unsigned long free = (unsigned long)&free -
+			     (unsigned long)end_of_stack(current);
+	return free >= THREAD_SIZE/3 ;
+#endif
+}
+

This will always fail when we are on an interrupt stack,
I think you'd want it to succeed in such a case.

Can you agree that, at least to a point, this is getting a bit
convoluted and perhaps adding more complexity than this optimization
deserves? :-)

