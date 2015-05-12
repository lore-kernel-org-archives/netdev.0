From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: sched: use counter to break reclassify loops
Date: Tue, 12 May 2015 15:00:29 +0200
Message-ID: <20150512130029.GA22387@breakpoint.cc>
References: <1431366641-24735-1-git-send-email-fw@strlen.de>
 <5551E62D.5040507@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39970 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932789AbbELNAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 09:00:32 -0400
Content-Disposition: inline
In-Reply-To: <5551E62D.5040507@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Florian,
> In general i am in support of removing this - since the use case never
> materialized as being useful. However, this is not the same logic that
> was there before. To get equivalency you need to pass the limit into
> tc_classify_compat() so i can be reset.

AFAICS this re-set only happens when we return something other
than RECLASSIFY which means the caller will not check the limit.

So in fact it should be ok to remove this since the counter will always
start from 0 on next tc_classify() invocation.

> BTW, a faster way to recreate
> tc filter add dev eth0 parent ffff: \
>   protocol ip u32 match u32 0 0 \
> action reclassify

Indeed, thanks for the hint.
