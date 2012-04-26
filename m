From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 03:09:32 -0700
Message-ID: <CANP3RGdnZk5b-gMkF8BPScrp9xos4X1u3n58ocuBQhTT7taE8A@mail.gmail.com>
References: <1335427854.2775.15.camel@edumazet-glaptop>
	<20120426.043623.1317043382565428400.davem@davemloft.net>
	<1335431402.2775.24.camel@edumazet-glaptop>
	<20120426.051800.637617874638567499.davem@davemloft.net>
	<1335432147.2775.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, ycheng@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:37236 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754353Ab2DZKJd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 06:09:33 -0400
Received: by vcqp1 with SMTP id p1so758954vcq.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 03:09:32 -0700 (PDT)
In-Reply-To: <1335432147.2775.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it would be very useful if there was an api for freeing skb->head memor=
y...

I've fooled around with a single memory buffer for both the head and
the data and seen huge performance wins under heavy packet load (half
the amount of malloc/free), but could never quite get it to be 100%
stable.

On Thu, Apr 26, 2012 at 2:22 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Thu, 2012-04-26 at 05:18 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 26 Apr 2012 11:10:02 +0200
>>
>> > The 'frag' would have a known size : 2048 bytes
>> >
>> > But the end of it would be used by struct skb_shared_info
>> >
>> > so data_len would be 0 in fact.
>> >
>> > This would look like a regular linear skb.
>> >
>> > Just a bit set in skb to say : Warning, skb->head was not kmalloce=
d :
>> > replace kfree(head) by put_page(...)
>> >
>> > And this bit would be tested in GRO or tcp merge to 'upgrade' this
>> > skb->head to proper page/frag
>>
>> And what happens if this ends up in a piece of code which wants to
>> append a page frag?
>>
>> Or a piece of code which copies an SKB, including page frag parts?
>>
>> All I'm saying is that the number of tests necessary to make this wo=
rk
>> properly might become prohibitive.
>
> I'll cook a patch, I believe not so many parts assume skb->head can b=
e
> kmalloc()/kfree(). This should be contained in net/core/skbuff.c only=
=2E
>
> Elsewhere we use skb->head as a pointer to memory. It will stay the
> same.
>
>
>



--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
1600 Amphitheatre Parkway, Mountain View, CA 94043
tel: +1 (650) 253-0062
