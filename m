From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 0/5] replace skb tc_verd member with 3 dedicated
 bit flags
Date: Tue, 5 May 2015 13:47:33 +0200
Message-ID: <20150505114733.GE17061@breakpoint.cc>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
 <5548ABF8.5080806@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48634 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752918AbbEELrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 07:47:35 -0400
Content-Disposition: inline
In-Reply-To: <5548ABF8.5080806@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Initial feedback on the series:
> - Can you keep the macros around? eg SET_TC_NCLS is more readable
> than skb->tc_nocls = 1 also hides the bit details.

I beg to differ, sorry :-/

We use blah:1 everywhere else in sk_buff, only tc is different and
its not obvious (to me) how tc_verd is being used and for what.

Or are you saying that should redefine SET_TC_NCLS to something like

#define SET_TC_NCLS(skb)	(skb)->tc_nocls = 1

?

> I think the ones that are no longer needed should just be deleted
> as opposed to what you and Alexei did earlier.

Fair enough, I can do that.

> - We need two bits for the location (ingress, egress, from stack)
> from stack being 0 i.e when it is not set implicitly it is from the
> host stack then we can check for ingress or egress when we choose.

Hmm, are you sure?  How is that used?

In fact ifb will BUG() if neither AT_INGRESS or AT_EGRESS was set
in G_TC_FROM().

Thanks for reviewing!
