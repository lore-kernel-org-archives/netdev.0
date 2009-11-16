From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: sparse vs. skbuff.h
Date: Mon, 16 Nov 2009 21:23:59 +0100
Message-ID: <19f34abd0911161223s3ead190aka62bf4295a3f935@mail.gmail.com>
References: <1258399271.32159.39.camel@johannes.local>
	 <1258399627.32159.41.camel@johannes.local>
	 <4B01AD5F.7020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:51909 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513AbZKPUXz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 15:23:55 -0500
Received: by bwz27 with SMTP id 27so6079525bwz.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 12:23:59 -0800 (PST)
In-Reply-To: <4B01AD5F.7020402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/11/16 Eric Dumazet <eric.dumazet@gmail.com>:
> Johannes Berg a =C3=A9crit :
>> On Mon, 2009-11-16 at 20:21 +0100, Johannes Berg wrote:
>>> commit 14d18a81b5171d4433e41129619c75748b4f4d26
>>> Author: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: =C2=A0 Thu Oct 29 00:10:37 2009 +0000
>>>
>>> =C2=A0 =C2=A0 net: fix kmemcheck annotations
>>>
>>>
>>> broke sparse endian checks on everything that includes skbuff.h bec=
ause
>>> the first and only (because it's an error) thing sparse now reports=
 is
>>> this:
>>>
>>> include/linux/skbuff.h:357:41: error: invalid bitfield specifier fo=
r type restricted __be16.
>>
>> Simply changing from
>> =C2=A0 =C2=A0 =C2=A0 __be16 protocol:16;
>> to
>> =C2=A0 =C2=A0 =C2=A0 __be16 protocol;
>>
>> but leaving it inside the kmemcheck annotation seems to do the right
>> thing. Except of course that kmemcheck will not properly check it no=
w.
>> Maybe those annotations should simply be made to have no impact on
>> struct padding instead?
>>
>
> Hmm, I have really no idea of what is the right way to fix this stuff=
=2E
>
> Last time I did adding a non bitfield element inside the begin/end an=
notations,
> I was flamed, because a bitfield is a bitfield, not a char/short
>
> http://www.spinics.net/lists/netdev/msg108803.html
>
> Now sparse is complaining... What will be the next story ?

If by "I was flamed" you are referring to my reply:

http://www.spinics.net/lists/netdev/msg108825.html

then I am really sorry, because I had no intentions to insult you. In
fact, I am grateful that you are finding bugs and telling me about
them But I should also be allowed to disagree with a patch if I truly
believe it is the wrong thing to do.

=46or the issue in question: If the variable is turned into a
non-bitfield (as Johannes suggested), it would be fine, because now
GCC won't emit masking operations (AND, OR) when initializing it, but
a regular MOV. Also, the struct annotations do not by themselves do
anything, but they are used by kmemcheck_annotate_bitfield().

In other words, I think the right thing to do is to turn it into a
non-bitfield and move it _outside_ the bitfield annotation. Johannes,
can you make the patch and let us have a look? In the meantime I will
submit the patch that fixes the extraneous field padding in
KMEMCHECK=3Dn kernels.


Vegard
