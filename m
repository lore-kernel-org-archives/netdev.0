From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next v2 1/2] syncookies: remove ecn_ok validation when
 decoding option timestamp
Date: Fri, 31 Oct 2014 14:39:48 +0100
Message-ID: <20141031133948.GJ10069@breakpoint.cc>
References: <1414757602-27637-1-git-send-email-fw@strlen.de>
 <1414757602-27637-2-git-send-email-fw@strlen.de>
 <1414762333.499.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41042 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758471AbaJaNju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 09:39:50 -0400
Content-Disposition: inline
In-Reply-To: <1414762333.499.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-31 at 13:13 +0100, Florian Westphal wrote:
> > Won't work anymore when tcp_ecn=0 and RTAX_FEATURES route attribute did
> > allow ecn.
> > 
> > Just turn on ecn if the client ts says so.
> > 
> > This means that while syn cookies are in use clients can turn on ecn
> > even if it is off on the server.
> > 
> > However, there seems to be no harm in permitting this.
> > 
> > Alternatively one can extend the test to also perform route lookup and
> > check RTAX_FEATURES, but it simply doesn't appear to be worth the effort.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  Changes since v1:
> >   - reword commit message
> 
> Sorry.
> 
> Google chose to disable ecn on their GFE, so we set sysctl_tcp_ecn to 0
> 
> If I understand your patch, if a synflood is going on, some innocent
> connections could get ECN enabled, while we do not want this to ever
> happen. ECN really hurts our customers, this is a known fact.
>
> You cannot change this like that, it would force us (and maybe others)
> to either revert this patch, or add a knob.

Mot needed, if you think its wrong to remove the check, I will respin
with a proper validation.

> If sysctl_tcp_ecn = 0, there is no way a connection should have ECN
> enabled. This was documented years ago.

It would only get enabled if the echoed timestamp (ie the timestamp we
sent in the synack) indicates that ecn was enabled, i.e. the client or
a middlebox would have to munge/modify it to set the 'ecn on' bit in the
timestamp.

If that is too fragile in your opinion I will respin the patch to include
the additional validation via dst.  We already need to fetch the dst
object anyway to fetch certain route attributes not in the timestamp or
cookie, so its only a matter of reorganizing code first to avoid two lookups.

Let me know what you prefer.

Thanks,
Florian
