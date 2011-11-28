From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [NET][TG3] Fwd: page allocation failure with linux 3.1.1
Date: Mon, 28 Nov 2011 11:05:53 -0800
Message-ID: <4ED3DB91.9090409@hp.com>
References: <CALkh-HhkzHb7-2LAwCNOZ-S4otfeM+tthyw2_XDbDUjFRSkKjA@mail.gmail.com> <CALkh-HiaDSJb7sStH=DHxXCmecFWYAC2q7hx72gGvFSYz+2r=A@mail.gmail.com> <1322462145.2826.6.camel@edumazet-laptop> <CALkh-Hi=Pb_cNUzHrJSe4o5-kmb+jLA8vpw8hiaGxROzNJ6oag@mail.gmail.com> <1322468762.2826.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?0J/Qu9Cw0LzQtdC9INCf0LXRgtGA0L7Qsg==?=
	<plamen.sisi@gmail.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:18821 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190Ab1K1TFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 14:05:55 -0500
In-Reply-To: <1322468762.2826.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2011 12:26 AM, Eric Dumazet wrote:
> Le lundi 28 novembre 2011 =C3=A0 09:16 +0200, =D0=9F=D0=BB=D0=B0=D0=BC=
=D0=B5=D0=BD =D0=9F=D0=B5=D1=82=D1=80=D0=BE=D0=B2 a =C3=A9crit :
>
>> Well, Eric, thanks for the explanation! I will disable TSO and will
>> see how is that working out for me - if I recall correctly, I had no
>> problems when TSO was off.
>>
>> Sorry to bother you, if the above explanation was somewhere readily
>> available, but I didn't manage to find it.
>
> You dont bother me at all :)
>
> As a matter of fact, your mail reminded me something I wanted to do i=
n
> the past and forgot about.
>
> Since some devices might copy skb to a linear one in their
> ndo_start_xmit(), we could set a netdev limit so that TSO can still b=
e
> used on these devices, but limiting number of frags to
> 2^PAGE_ALLOC_COSTLY_ORDER

How much "TSO value" remains after such a copy?

rick jones

>
> (Since PAGE_ALLOC_COSTLY_ORDER =3D=3D 3, thats 8 frags, instead of 16=
 right
> now on x86)
>
> Of course, if memory is really tight, even an ATOMIC order-3 allocati=
on
> might fail. If this happens, device limit could be dynamically
> decreased. In the end, only linear skb could be built by TCP.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
