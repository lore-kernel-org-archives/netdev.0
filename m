From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Tue, 8 Dec 2015 14:44:13 +0100
Message-ID: <5666DEAD.6010202@stressinduktion.org>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
 <1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
 <87vb8fjpou.fsf@nemi.mork.no>
 <1449225712.287884.457895729.21AD000E@webmail.messagingengine.com>
 <87d1ukk9ce.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:59659 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756289AbbLHNoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 08:44:16 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id B7A97208CF
	for <netdev@vger.kernel.org>; Tue,  8 Dec 2015 08:44:15 -0500 (EST)
In-Reply-To: <87d1ukk9ce.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.12.2015 20:02, Bj=C3=B8rn Mork wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>> On Thu, Dec 3, 2015, at 20:29, Bj=C3=B8rn Mork wrote:
>>
>>> After looking more at addrconf, I started wondering if we couldn't =
abuse
>>> ipv6_generate_stable_address() for this purpose?  We could add a ne=
w
>>> addr_gen_mode which would trigger automatic generation of a secret =
if
>>> stable_secret is uninitialized.  This would be good enough to ensur=
e
>>> stability until the interface is destroyed.  And it would still all=
ow
>>> the adminstrator to select IN6_ADDR_GEN_MODE_STABLE_PRIVACY by ente=
ring
>>> a new secret.
>>
>> I am fine with your proposal but I would really like to see it only
>> happen on the per-interface stable_secret instance.
>=20
> Do you think something like the patch below will be OK?

I wouldn't call it IN6_ADDR_GEN_MODE_AUTO, this doesn't say anything.
But the idea is already good.

> Or would it be better to drop the additional mode and just generate a
> random secret if the mode is IN6_ADDR_GEN_MODE_STABLE_PRIVACY and the
> secrets are missing?  Or would that be changing the userspace ABI?  T=
his
> is not clear to me...

I would not like to do that somehow. The problem is that the stable
secrets get written by user space probably during boot-up, but we don't
know when. That's why I would also not set the ->initialized flag, so
user can overwrite it to the final secret later on. We block it otherwi=
se.

My proposal would be to use the stable privacy generator in case the
device does not have a device address for EUI-48 generation with a
secret which we simply generate on the stack. Let's factor out the part
of the generator which depends on the inet6_dev and cnf bits for that.

What do you think?

Bye,
Hannes
