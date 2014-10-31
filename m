From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next v2 1/2] syncookies: remove ecn_ok validation when
 decoding option timestamp
Date: Fri, 31 Oct 2014 15:15:03 +0100
Message-ID: <20141031141503.GL10069@breakpoint.cc>
References: <1414757602-27637-1-git-send-email-fw@strlen.de>
 <1414757602-27637-2-git-send-email-fw@strlen.de>
 <1414762333.499.16.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141031133948.GJ10069@breakpoint.cc>
 <1414764287.27538.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41141 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759376AbaJaOPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 10:15:05 -0400
Content-Disposition: inline
In-Reply-To: <1414764287.27538.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-31 at 14:39 +0100, Florian Westphal wrote:
> 
> > It would only get enabled if the echoed timestamp (ie the timestamp we
> > sent in the synack) indicates that ecn was enabled, i.e. the client or
> > a middlebox would have to munge/modify it to set the 'ecn on' bit in the
> > timestamp.
> > 
> > If that is too fragile in your opinion I will respin the patch to include
> > the additional validation via dst.  We already need to fetch the dst
> > object anyway to fetch certain route attributes not in the timestamp or
> > cookie, so its only a matter of reorganizing code first to avoid two lookups.
> 
> Well, your changelog is so confusing, I have no idea what is your
> intent.

Sorry :-/

So if you have a per route ecn setting, and syncookies are used,
and tcp_ecn sysctl is 0:

1. we receive syn with ecn on and timestamps
2. we send cookie synack, with timestamp and ecn (route allowed it),
the lower bits of the timestamp have a "magic" bit set that allows
us to infer that ecn was negotiated successfully.
3. we drop the ack from the client, since timestamp decoding sees
"ecn is on according to timestamp, but the tcp_ecn sysctl is off".

So to fix this, step 3 either has to check the dst setting
in addition to the global sysctl, or to rely on the timestamp alone
that ecn was requested by the original client and allowed by our host
at the time synack timestamp was generated/sent.

I hope that explains the reason behind patch #1 up.

> I do not really understand why you need to change something.

Yes, unfortunately you're not the first person saying that my
changelogs are not precise enough sometimes, I hope to do
a better job next time around.

> Maybe this is because I have not yet took my coffee ;)

Oh, well, that could also explain it 8-)
