From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sparse vs. skbuff.h
Date: Mon, 16 Nov 2009 21:42:52 +0100
Message-ID: <4B01B94C.4050401@gmail.com>
References: <1258399271.32159.39.camel@johannes.local>	 <1258399627.32159.41.camel@johannes.local>	 <4B01AD5F.7020402@gmail.com> <19f34abd0911161223s3ead190aka62bf4295a3f935@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34456 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbZKPUnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 15:43:05 -0500
In-Reply-To: <19f34abd0911161223s3ead190aka62bf4295a3f935@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vegard Nossum a =C3=A9crit :
> 2009/11/16 Eric Dumazet <eric.dumazet@gmail.com>:
>> Johannes Berg a =C3=A9crit :
>>> On Mon, 2009-11-16 at 20:21 +0100, Johannes Berg wrote:
>>>> commit 14d18a81b5171d4433e41129619c75748b4f4d26
>>>> Author: Eric Dumazet <eric.dumazet@gmail.com>
>>>> Date:   Thu Oct 29 00:10:37 2009 +0000
>>>>
>>>>     net: fix kmemcheck annotations
>>>>
>>>>
>>>> broke sparse endian checks on everything that includes skbuff.h be=
cause
>>>> the first and only (because it's an error) thing sparse now report=
s is
>>>> this:
>>>>
>>>> include/linux/skbuff.h:357:41: error: invalid bitfield specifier f=
or type restricted __be16.
>>> Simply changing from
>>>       __be16 protocol:16;
>>> to
>>>       __be16 protocol;
>>>
>>> but leaving it inside the kmemcheck annotation seems to do the righ=
t
>>> thing. Except of course that kmemcheck will not properly check it n=
ow.
>>> Maybe those annotations should simply be made to have no impact on
>>> struct padding instead?
>>>
>> Hmm, I have really no idea of what is the right way to fix this stuf=
f.
>>
>> Last time I did adding a non bitfield element inside the begin/end a=
nnotations,
>> I was flamed, because a bitfield is a bitfield, not a char/short
>>
>> http://www.spinics.net/lists/netdev/msg108803.html
>>
>> Now sparse is complaining... What will be the next story ?
>=20
> If by "I was flamed" you are referring to my reply:
>=20
> http://www.spinics.net/lists/netdev/msg108825.html
>=20
> then I am really sorry, because I had no intentions to insult you. In
> fact, I am grateful that you are finding bugs and telling me about
> them But I should also be allowed to disagree with a patch if I truly
> believe it is the wrong thing to do.

Oh well, maybe flamed is not the right word Vegard, and I did not feel
being insulted at all ! Sorry if the tone of my mail was misleading.

>=20
> For the issue in question: If the variable is turned into a
> non-bitfield (as Johannes suggested), it would be fine, because now
> GCC won't emit masking operations (AND, OR) when initializing it, but
> a regular MOV. Also, the struct annotations do not by themselves do
> anything, but they are used by kmemcheck_annotate_bitfield().
>=20
> In other words, I think the right thing to do is to turn it into a
> non-bitfield and move it _outside_ the bitfield annotation. Johannes,
> can you make the patch and let us have a look? In the meantime I will
> submit the patch that fixes the extraneous field padding in
> KMEMCHECK=3Dn kernels.
>=20

Thanks
