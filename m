From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Mon, 14 Dec 2015 22:43:30 +0100
Message-ID: <87bn9semf1.fsf@nemi.mork.no>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
	<1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
	<87vb8fjpou.fsf@nemi.mork.no>
	<1449225712.287884.457895729.21AD000E@webmail.messagingengine.com>
	<87d1ukk9ce.fsf@nemi.mork.no> <5666DEAD.6010202@stressinduktion.org>
	<87d1ugzs3f.fsf@nemi.mork.no> <566F3504.6050908@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42921 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932088AbbLNVnh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:43:37 -0500
In-Reply-To: <566F3504.6050908@stressinduktion.org> (Hannes Frederic Sowa's
	message of "Mon, 14 Dec 2015 22:30:44 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> Sorry for answering so late...

No problem.  There is no rush here AFAICS.  Thanks for taking the time
to look at this.

> What do you think about simply using IN6_ADDR_GEN_MODE_RANDOM?

Yes, that's fine with me (actually what I first used :)

>> I guess we should check &net->ipv6.devconf_dflt->stable_secret too
>> before choosing the default mode.  IN6_ADDR_GEN_MODE_STABLE_PRIVACY =
is a
>> more approproate default if a default secret is set.  IMHO, this sho=
uld
>> really be the case without the proposed change too, but it isn't. Th=
e
>> current behaviour confuses me: Setting 'default' changes all existin=
g
>> interfaces, but does not change the default for new interfaces. Is t=
hat
>> right?
>
> Nope, that is a good point. I think we should do that unconditionally=
=2E
> If we have a stable secret set, which we can use, we always should us=
e
> this address generation mode. Can you send the addition of this as a
> separate patch so we can propose it for stable? Otherwise I can do th=
at,
> too.

I can do that if it can wait for whenever I get around to actually
submit this.  No guarantee that will be in time for v4.5.


>>> My proposal would be to use the stable privacy generator in case th=
e
>>> device does not have a device address for EUI-48 generation with a
>>> secret which we simply generate on the stack. Let's factor out the =
part
>>> of the generator which depends on the inet6_dev and cnf bits for th=
at.
>>=20
>> Not sure I get this part either.  The point was to have stable addre=
sses
>> for the lifetime of the netdev.  We can generate the secret on the
>> stack, but we will still need to stash it somewhere.  That could of
>> course be to a new field.  But I don't see the point since there is =
no
>> way you can combine this mode with IN6_ADDR_GEN_MODE_STABLE_PRIVACY.
>> Only one mode can be active at, and that mode can then own the secre=
t.
>
> Ok, your argument makes sense.
>
>> As long as we can manage to introduce this without changing any exis=
ting
>> behaviour, of course.
>
> Besides the naming I think your patch looks fine.

Thanks!  Will fixup that and formally submit when I find some time.


Bj=C3=B8rn
