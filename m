From: jamal <hadi@cyberus.ca>
Subject: Re: Billing 3-3: WAS(Re: [PATCH 2/4] deferred drop, __parent
	workaround, reshape_fail , netdev@oss.sgi.com ,
Date: 23 Aug 2004 08:15:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093263300.1039.797.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>
	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>
	 <1093191124.1043.206.camel@jzny.localdomain>
	 <4129BB3A.9000007@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <4129BB3A.9000007@crocetta.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-23 at 05:39, sandr8 wrote:
>jamal wrote:

Let me just get to the bottom of your email:

[..]
> >A packet that gets enqueued is _guaranteed_ to be transmitted unless
> >overulled by admin policy. 
> >Ok, how about the idea of adding skb->unbilled which gets set when
> >unbilling happens (in the aggregated stats_incr()). skb->unbilled gets
> >zeroed at the root qdisc after return from enqueueing.
> >  
> >
> sorry?? i'm lost... maybe there's something implied i can't get...
> do you agree it's not the same skb that will be re-billed
> afterwards?

Sure, its a cloned packet - from a billing perspective we can look at it
as a different flow. Contrack bills, qdisc unbills.
What i meant is packet still flowing within the qdisc infrastructure.
what i drew as:
   ..-->classification --> tcaction
return code1 --> enqueue
return code2 ...(packet may be freed here)--> dev.c

Thats the only place i see skb->unbilled as useful.

So:
all components need to increment their won proivate stats and should
call stats_incr() but only the first one gets to unbill;
eg if action calls stats_incr to indicate drop; you unbill. When
qdisc enqueue calls stats_incr with a drop reason, you dont want to
unbill again.

We could talk in more details about code after - just discussing
concepts right now.

cheers,
jamal
