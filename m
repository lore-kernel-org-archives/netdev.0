From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] mv643xxx_eth_start_xmit oops
Date: Fri, 10 Nov 2006 22:03:43 +0100
Message-ID: <20061110210343.GA9453@electric-eye.fr.zoreil.com>
References: <20061110191745.GA13783@codepoet.org> <20061110115444.07f58e40@freekitty> <20061110205327.19468.qmail@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56238 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1161909AbWKJVEm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 16:04:42 -0500
To: Dale Farnsworth <dale@farnsworth.org>
Content-Disposition: inline
In-Reply-To: <20061110205327.19468.qmail@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth <dale@farnsworth.org> :
[...]
> Can you provide more detail about the leak?

+       if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
+               stats->tx_dropped++;
+               if (net_ratelimit())
+                       printk(KERN_DEBUG "%s: failed to linearize tiny "
+                              "unaligned fragment\n", dev->name);
+               return NETDEV_TX_OK;

Missing kfree_skb(skb) before returning NETDEV_TX_OK ?

-- 
Ueimor
