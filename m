From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp cache
Date: Wed, 15 Mar 2017 23:57:26 +0100
Message-ID: <20170315225726.GA28498@breakpoint.cc>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
 <20170315.154044.170788541865531834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: soheil.kdev@gmail.com, netdev@vger.kernel.org, soheil@google.com,
        edumazet@google.com, ncardwell@google.com, ycheng@google.com,
        lvml@5t9.de, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:49142 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752035AbdCOW5z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:57:55 -0400
Content-Disposition: inline
In-Reply-To: <20170315.154044.170788541865531834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
> Date: Wed, 15 Mar 2017 16:30:45 -0400
> 
> > Note that this cache was already broken for caching timestamps of
> > multiple machines behind a NAT sharing the same address.
> 
> That's the documented, well established, limitation of time-wait
> recycling.

Sigh.

"don't enable this if you connect your machine to the internet".
We're not in the 1990s anymore.  Even I am behind ipv4 CG-NAT nowadays.

So I disagree and would remove this thing.

> This limitation of the feature does not give us a reason to break the
> feature even further as a matter of convenience, or to remove it
> altogether for the same reason.
> 
> Please, instead, fix the bug that was introduced.

AFAIU we only have two alternatives, removal of the randomization feature
or switch to a offset computed via hash(saddr, daddr, secret).

Unless there are more comments I'll look into doing the latter tomorrow.
