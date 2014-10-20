From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/4] net: make skb_gso_segment error handling more robust
Date: Mon, 20 Oct 2014 09:05:04 +0200
Message-ID: <20141020070504.GC4626@breakpoint.cc>
References: <1413751340-19621-1-git-send-email-fw@strlen.de>
 <1413751340-19621-3-git-send-email-fw@strlen.de>
 <20141019.203943.579204096575757665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41762 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752480AbaJTHFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 03:05:07 -0400
Content-Disposition: inline
In-Reply-To: <20141019.203943.579204096575757665.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sun, 19 Oct 2014 22:42:19 +0200
> 
> > skb_gso_segment has three possible return values:
> > 1. a pointer to the first segmented skb
> > 2. an errno value (IS_ERR())
> > 3. NULL.  This can happen when GSO is used for header verification.
> > 
> > However, several callers currently test IS_ERR instead of IS_ERR_OR_NULL
> > and would oops when NULL is returned.
> > 
> > Note that these call sites should never actually see such a NULL return
> > value; all callers mask out the GSO bits in the feature argument.
> > 
> > However, in the past, there have been issues with some protocol handlers
> > erronously not respecting the specified feature mask in some cases.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> I don't think it makes sense to return PTR_ERR(p) when
> p is NULL.

Good point. Will respin.
