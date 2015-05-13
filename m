From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: sched: use counter to break reclassify loops
Date: Wed, 13 May 2015 14:44:10 +0200
Message-ID: <20150513124410.GB6179@breakpoint.cc>
References: <1431366641-24735-1-git-send-email-fw@strlen.de>
 <5551E62D.5040507@mojatatu.com>
 <20150512130029.GA22387@breakpoint.cc>
 <55533321.302@mojatatu.com>
 <20150513112958.GA6179@breakpoint.cc>
 <55533DCB.2070703@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43095 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934149AbbEMMoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 08:44:12 -0400
Content-Disposition: inline
In-Reply-To: <55533DCB.2070703@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 05/13/15 07:29, Florian Westphal wrote:
> >Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> >Yes, but, if we use your example above then:
> >
> >tc_classify called
> >   limit 0
> >     tc_classify_compat called, ret RECLASSIFY
> >   limit 1
> >     tc_classify_compat called, ret RECLASSIFY
> >   limit 2
> >     tc_classify_compat called, ret PIPE (== 3)
> >   tc_classify returns 3
> >tc_classify called
> >   limit 0
> >   ...
> >
> >So we don't toss skb since any return value other than RECLASSIFY
> >will make tc_classify() return to its caller, and when caller invokes
> >tc_classify again the limit variable is set to 0 again.
> >
> >Does that make sense to you?
> >
> 
> I think you are right.

[..]

> In any case, lets not slow this down; please add my acked-by and if
> i can think of something i will post. I have to take off, so i will go
> quiet for a while.

Ok.  Again, many thanks Jamal for all the help you've provided.

In case you were not aware: thanks to patchwork its enough to reply with

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

... and it will be appended to the patch automagically.
