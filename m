From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gro: small napi_get_frags() optim
Date: Thu, 05 Dec 2013 22:26:28 -0800
Message-ID: <1386311188.30495.238.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386308667.30495.230.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386310268.31845.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:34752 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab3LFG0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:26:30 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so488823pbc.38
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 22:26:30 -0800 (PST)
In-Reply-To: <1386310268.31845.13.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 22:11 -0800, Joe Perches wrote:

> Thanks, I agree this patch is appropriate as skb is unlikely
> to be NULL in normal cases.

We do not care if skb is NULL or not.

> 
> But just for thought: isn't the test expense essentially
> free when skb is in a register vs the member set cost?
> 

Test is not 'free', even if predicted.

Study the generated assembly code if you are interested, you'll see this
makes a difference.

> Also, netdev_alloc_skb_ip_align is static inline and it has
> a test of
> 	if (NET_IP_ALIGN && skb)
> just before the return so this "if (skb)" test could already
> be elided by a good compiler but this change requires an
> unconditional set.

NET_IP_ALIGN is 0 on x86, even a 'bad' compiler zaps the whole thing.
