From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Fri, 2 May 2008 22:39:58 +0200
Message-ID: <200805022239.58699.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804282303.40673.tomasz@grobelny.oswiecenia.net> <20080430075332.GA4277@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2412 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936588AbYEBUkx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:40:53 -0400
In-Reply-To: <20080430075332.GA4277@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Wednesday 30 of April 2008, Gerrit Renker napisa=B3:
> | c) allow qpolicy to use each cmsg header as different parameter. So=
 that
> (...)
> I think (c) is best, here is what I'd support.
> (...)
Seems we are getting closer in our views, see the just sent patch.

> Ok, but this is a separate question and it is about a yet non-existin=
g
> policy.
>
Hopefully someone, someday will implement it. So it is good to have a b=
asic=20
idea how it might work.

> So far there is a "priority" policy, for which I think we agree that =
32
> bits are enough.
>
=46or storing just priority - yes. I'd even say that it is too much...

> And both associated parameters can be parsed differently, in particul=
ar
> there is no requirement to restrict DCCP_SCM_TIMEOUT to use 32 bits -=
 it
> could even pass a struct timeval or struct timespec.
>
Yes, that's nice.

> Then there is a yet non-existing "timeout" policy, which has no assoc=
iated
> field yet. If we can assume that e.g. the skb->tstamp field can be us=
ed
> to store timeouts, then there are separate fields associated with sep=
arate
> policies.
>
> Thirdly, there is the aggregate policy "priority+timeout", which can
> then use both skb->priority and skb->tstamp.
>
> I.e. to answer the question, I think it is best to implement "timeout=
"
> first, solve the problems it brings up; when that is done,
> "priority+timeout" will be easy to do - it could be constructed just =
out of
> the existing functions defined for "priority" and "timeout".
>
> In that manner, other policies can be modularly constructed - for ins=
tance
> by combining "timeout" with a different form of the "priority" policy=
=2E
>
I'm not entirely sure if such modular constructions would be possible. =
I=20
prefer to think of "timeout policy" and "prio policy" as a special case=
s=20
of "timeout+prio policy" with respectively DCCP_SCM_PRIORITY and=20
DCCP_SCM_TIMEOUT not supplied (and thus set to their default values: 0 =
and=20
INFINITY).
--=20
Regards,
Tomasz Grobelny
