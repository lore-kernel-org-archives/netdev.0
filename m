From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sparse vs. skbuff.h
Date: Mon, 16 Nov 2009 20:51:59 +0100
Message-ID: <4B01AD5F.7020402@gmail.com>
References: <1258399271.32159.39.camel@johannes.local> <1258399627.32159.41.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Vegard Nossum <vegard.nossum@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52225 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbZKPTv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 14:51:57 -0500
In-Reply-To: <1258399627.32159.41.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg a =C3=A9crit :
> On Mon, 2009-11-16 at 20:21 +0100, Johannes Berg wrote:
>> commit 14d18a81b5171d4433e41129619c75748b4f4d26
>> Author: Eric Dumazet <eric.dumazet@gmail.com>
>> Date:   Thu Oct 29 00:10:37 2009 +0000
>>
>>     net: fix kmemcheck annotations
>>
>>
>> broke sparse endian checks on everything that includes skbuff.h beca=
use
>> the first and only (because it's an error) thing sparse now reports =
is
>> this:
>>
>> include/linux/skbuff.h:357:41: error: invalid bitfield specifier for=
 type restricted __be16.
>=20
> Simply changing from
> 	__be16 protocol:16;
> to
> 	__be16 protocol;
>=20
> but leaving it inside the kmemcheck annotation seems to do the right
> thing. Except of course that kmemcheck will not properly check it now=
=2E
> Maybe those annotations should simply be made to have no impact on
> struct padding instead?
>=20

Hmm, I have really no idea of what is the right way to fix this stuff.

Last time I did adding a non bitfield element inside the begin/end anno=
tations,
I was flamed, because a bitfield is a bitfield, not a char/short

http://www.spinics.net/lists/netdev/msg108803.html

Now sparse is complaining... What will be the next story ?

