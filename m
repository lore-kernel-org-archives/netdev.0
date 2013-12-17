From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: distribute vxlan tunneled traffic across multiple
 TXQs
Date: Tue, 17 Dec 2013 08:45:26 -0800
Message-ID: <1387298726.19078.261.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387269626-12463-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:50859 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab3LQQpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 11:45:32 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so4688397pab.15
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 08:45:32 -0800 (PST)
In-Reply-To: <1387269626-12463-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 14:10 +0530, Sathya Perla wrote:
> TX traffic is distributed across multiple TXQs using skb->sk->sk_hash.
> For vxlan skbs, the reference to the original socket (skb->sk) is replaced
> with vxlan-sk. Because of this all tunneled traffic ends up only on one TXQ.
> 
> This patch uses the skb->rxhash field to carry the original sk->sk_hash
> value so that it can be used by netdev layer to pick a TXQ. If this approach
> is agreeable then we can change the name of skb->rxhash to skb->hash so that
> it can be used in both RX and TX paths.
> 
> But, after a TXQ is picked based on the skb->rxhash for tunneled traffic,
> it's index cannot be recorded in the original socket as it's reference
> is no longer available in skb. So, the TXQ-index would need to be
> computed (from skb->rxhash) for each skb. Any ideas on how this can be
> avoided?

Real question is : Why vxlan needs to set a skb destructor ?  

skb_orphan(skb) breaks TCP Small queues and FQ/pacing packet scheduler,
plus other things...
