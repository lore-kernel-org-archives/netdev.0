From: tsuna <tsunanet@gmail.com>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Wed, 18 May 2011 12:40:21 -0700
Message-ID: <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
References: <1305619677.2850.11.camel@edumazet-laptop> <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
 <20110518.152653.1486764697527722925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518.152653.1486764697527722925.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 12:26 PM, David Miller <davem@davemloft.net> wr=
ote:
> If you read the ietf draft that reduces the initial RTO down to 1
> second, it states that if we take a timeout during the initial
> connection handshake then we have to revert the RTO back up to 3
> seconds.
>
> This fallback logic conflicts with being able to only change the
> initial RTO via sysctl, I think. =A0Because there are actually two
> values at stake and they depend upon eachother, the initial RTO and
> the value we fallback to on initial handshake retransmissions.
>
> So I'd rather get a patch that implements the 1 second initial
> RTO with the 3 second fallback on SYN retransmit, than this patch.
>
> We already have too many knobs.

I was hoping this knob would be accepted because this is such an
important issue that it even warrants an IETF draft to attempt to
change the standard.  I'm not sure how long it will take for this
draft to be accepted and then implemented, so I thought adding this
simple knob today would really help in the future.

Plus, should the draft be accepted, this knob will still be just as
useful (e.g. to revert back to today's behavior), and people might
want to consider adding another knob for the fallback initRTO (this is
debatable).  I don't believe this knob conflicts with the proposed
change to the standard, it actually goes along with it pretty well and
helps us prepare better for this upcoming change.

I agree that there are too many knobs, and I hate feature creep too,
but I've found many of these knobs to be really useful, and the degree
to which Linux's TCP stack can be tuned is part of what makes it so
versatile.

--=20
Benoit "tsuna" Sigoure
Software Engineer @ www.StumbleUpon.com
