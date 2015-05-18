From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Mon, 18 May 2015 22:40:49 +0200
Message-ID: <20150518204049.GC20709@breakpoint.cc>
References: <1431032664-6478-1-git-send-email-fw@strlen.de>
 <20150518.153922.1873846748456446294.davem@davemloft.net>
 <20150518200637.GB20709@breakpoint.cc>
 <20150518.162854.1116793790405432801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, hannes@stressinduktion.org,
	edumazet@google.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54706 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932864AbbERUkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:40:52 -0400
Content-Disposition: inline
In-Reply-To: <20150518.162854.1116793790405432801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 18 May 2015 22:06:37 +0200
> 
> > So, please please re-evaluate your stance on any of the previous
> > attempts or tell me how you would provide bridge netfilter with
> > the means to transparently forward (refrag) reassembled skbs, without
> > breaking PMTUD, in ipv4 and ipv6.
> 
> I know you really don't want to do it, but I really want to see
> the "GRO'ish" idea implemented to solve all of these problems.
> 
> I know it's hard, and you're making it clear here that you'd
> rather just pass an mtu argument around or duplicate the entire
> ip fragmentation code base into br_netfilter to solve this problem.

Its not 'hard'.  I don't see how its possible to do this.

> But as networking maintainer I'm supposed to tell you "no" when
> those kinds of proposals are being made.  Ok?

Sure.

> We have amazing infrastructure for dealing with oddly segmented
> packets, such as skb_header_pointer().  So parsing things in
> a fragmented SKB should be no problem regardless of where the
> split points are.

Netfilter works fine with reassembled skbs that have frag lists.
Parsing is also not that much of a problem, modifying/growing is.

> We could have suitable interfaces for writing to packets as well,
> which would be equally fast as direct access unless the SKB is
> split in the middle of the object you want to write into.

When I send patches for inclusion in the kernel, I do this to fix
things, or I do it because I believe such patches improve kernel in some
way.

I try to imagine how e.g. the H264 or SIP nat helpers would look like
after such a change and it makes me cringe.

But, to the best of my understanding, what you ask will push a lot of
non-trivial code into the kernel for no functional gain over
what has been proposed.

But, even if we'd have magic solution that does what you want we've
gained nothing; there are (rare) cases where packets get completely modified
(e.g. payload is replaced from userspace/nfqueue; xfrm mangling, etc etc
 so we will not be able to escape this either).

Maybe I am just too incompetent.

I've tried the best I could do.  Perhaps someone else can pick this up.

Alas, I'll bring this up during NFWS 2015.  Maybe someone will know how
to do what you are asking.
