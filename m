From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 2/3] net: sched: remove AT INGRESS/EGRESS
Date: Sat, 16 May 2015 00:22:54 +0200
Message-ID: <20150515222254.GL6179@breakpoint.cc>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
 <1431679850-31896-3-git-send-email-fw@strlen.de>
 <20150515162319.GA8234@Alexeis-MBP.westell.com>
 <20150515172115.GK6179@breakpoint.cc>
 <20150515200944.GA8527@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	jhs@mojatatu.com, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49635 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964787AbbEOWW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 18:22:57 -0400
Content-Disposition: inline
In-Reply-To: <20150515200944.GA8527@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> On Fri, May 15, 2015 at 07:21:15PM +0200, Florian Westphal wrote:
> > So, from ifb point of view it makes no difference, G_TC_FROM+AT_STACK
> > causes skb to be dropped and IFB doesn't care about G_TC_AT() at all.
> 
> yes. your change is technically correct. It's not causing ifb regression,

Thanks.

> but it removes information in a way that will be very hard to add it later.

Are you sure?  Would you mind elaborating a bit?

> > AT_STACK cannot even happen for the G_TC_AT case from looking at the
> > code since dev_queue_xmit forces AT_EGRESS & rx sets AT_INGRESS.
> 
> yes, if we only consider ingress and egress hooks.
> I want to use this stack/ingress/egress indication with socket filters.

Hmm... I'm sorry, I fail to understand where problem is.

> If we make stack==egress, I would need to refactor this code all over again.

If you mean "skb was not forwarded", you could just check for
skb->skb_iif = 0?

If not, what info do you need, and why could we not extend proposed enum
if absolutely required?

> It's not broken today. You're doing this aliasing only two squeeze a bit.

Yep, but its was also to minimize the state machinery down to whats
required.

Sorry Alexei, I'm just trying to find out what exactly is needed,
perhaps if you can clarify/explain I might be able to re-spin this in a
way that will meet your requirements.
