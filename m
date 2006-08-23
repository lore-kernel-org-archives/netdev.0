From: jamal <hadi@cyberus.ca>
Subject: Re: multicast group memberships purge on interface delete
Date: Wed, 23 Aug 2006 10:48:18 -0400
Message-ID: <1156344498.26783.11.camel@jzny2>
References: <20060809.195627.59155708.yoshfuji@linux-ipv6.org>
	 <44D9D431.10101@tcs.hut.fi>	<44DA558A.1080706@tcs.hut.fi>
	 <20060810.174635.42119608.yoshfuji@linux-ipv6.org>
	 <44DB0870.6000902@tcs.hut.fi> <019901c6bc75$872ee1f0$2303a8c0@mruzicka>
	 <021e01c6c6a4$6e7845f0$2303a8c0@mruzicka> <1156336331.5035.79.camel@jzny2>
	 <039601c6c6b8$47b0f7a0$2303a8c0@mruzicka>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:7390 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964908AbWHWOsV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 10:48:21 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GFu1n-0002xa-U8
	for netdev@vger.kernel.org; Wed, 23 Aug 2006 10:48:23 -0400
To: Michal =?iso-8859-2?Q?R=F9=BEi=E8ka?= <michal.ruzicka@comstar.cz>
In-Reply-To: <039601c6c6b8$47b0f7a0$2303a8c0@mruzicka>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-23-08 at 15:29 +0200, Michal R=C5=AF=C5=BEi=C4=8Dka wrote:

> No need to rmmod anything, just think of ppp or gre interfaces which =
come=20
> and go
> without any modules loading/unloading. But yes, the rmmod would proba=
bly be
> needed in case of, for example, an ethernet device.
>=20

Ok - Same effect. i.e the same events would be generated if a gre
dissapears or an ethernet is rmmoded.

> > The challenge is to make the app
> > also aware of you taking away the group from underneath them (thats=
 why
> > i said "fix it")
> >
>=20
> I dont's see this as any challange as the applications could just ass=
ume=20
> that any
> memberships on deleted interfaces have been just droped implicitly by=
 the=20
> kernel.

How would they know that the interface has been deleted?
If you have the answer to that, then why dont you do the
unsubscriptions/leaves as well?

> (This should be no problem for them provided that they keep track of
> the interfaces present on the system, which they should anyway or oth=
erwise
> they could end up listening to just a part of the multicast traffic t=
hey are
> interested in.)
>=20

Right. So does your app do this?

> In fact I've had proposed that on the application mailing list (the=20
> appliaction is
> quagga formerly zebra routing suite to be specific) but the people th=
ere=20
> disliked
> it because of the fact that for example the NetBSD (as I noted in my=20
> previous
> post) does the group leaves implicitly on the interface delete and th=
e=20
> explicit
> group leaves fail there (and reportedly on other OSes too).
> Sure this can solved by some conditional compilation.
> This is why my post was more a theoretical design question/suggestion=
 than
> a feature request (or a bug report).
>=20
> In this sense what do you think about the possible benefit of the pro=
posed
> approach for maintaning the per-interface multicast reception state?

An arguement can be made that if you joined the groups from the app,
then the app should be responsible to unsubscribe. i.e this is a policy
decision.=20
You could have the kernel implement your policy as you described, but i=
n
my view you would have to tell it. And conditional compilation or some
way of telling the kernel would fit in such a case.
There is probably a good reason why NetBSD insists on doing it in the
kernel; do you know what this reason is?

cheers,
jamal



