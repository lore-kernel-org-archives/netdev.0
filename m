From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 4/4]: Kill fastpath_{skb,cnt}_hint.
Date: Wed, 28 Feb 2007 13:08:08 -0800
Message-ID: <20070228130808.4b7a9ea8@localhost.localdomain>
References: <20070228.114949.18302561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43863 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbXB1VK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 16:10:57 -0500
In-Reply-To: <20070228.114949.18302561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Feb 2007 11:49:49 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> 
> commit 71b270d966cd42e29eabcd39434c4ad4d33aa2be
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Tue Feb 27 19:28:07 2007 -0800
> 
>     [TCP]: Kill fastpath_{skb,cnt}_hint.
>     
>     Now that we have per-skb fack_counts and an interval
>     search mechanism for the retransmit queue, we don't
>     need these things any more.
>     
>     Instead, as we traverse the SACK blocks to tag the
>     queue, we use the RB tree to lookup the first SKB
>     covering the SACK block by sequence number.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>

I would be happy to see this go.  Have you tried this code with
a SACK DoS stream? I.e. before you could consume a huge amount
of cpu time by giving an certain bad sequence of SACK's. This
code should have a better worst case run time.
