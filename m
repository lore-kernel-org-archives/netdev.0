From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Mon, 13 Jan 2014 12:13:31 -0800
Message-ID: <CA+mtBx9O=sPnjebieBSg_PEbA4jwqAtbjs85V44SpAEaYNDeCw@mail.gmail.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	<1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	<20140113.115913.1269834557058575064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:42547 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbaAMUNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 15:13:31 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so1977058ief.9
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 12:13:31 -0800 (PST)
In-Reply-To: <20140113.115913.1269834557058575064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 11:59 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 10 Jan 2014 08:27:20 -0800
>
>> On Thu, Jan 9, 2014 at 9:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Thu, 2014-01-09 at 20:54 -0800, Tom Herbert wrote:
>>>> When initializing a gro_list for a packet, first check the rxhash of
>>>> the incoming skb against that of the skb's in the list. This should be
>>>> a very strong inidicator of whether the flow is going to be matched,
>>>> and potentially allows a lot of other checks to be short circuited.
>>>>
>>>
>>> Hmm... this idea was discussed in the past. I used it when attempting to
>>> use a hash table instead of a gro_list last year.
>>>
>>> Unfortunately this added lot of cycles when rxhash is not provided by
>>> hardware, and my tests found it was not a win.
>>>
>>> Remember : in most cases, gro_list contains one flow, so this test does
>>> nothing special but adds overhead.
>>
>> I don't understand what your basis is that gro_list in most cases
>> contains one flow
>
> It also doesn't jive well with Eric's recent patch to adjust the GRO
> overflow strategy (600adc18eba823f9fd8ed5fec8b04f11dddf3884 ("net:
> gro: change GRO overflow strategy"))
>
> :-)
>
> I sort of like Tom's idea to optimistically compare the hash, if we
> do in fact have one already.
>
> Eric would the change be OK if Tom did it that way?

btw, I'm also looking at "if ((a ^ b) | (c ^ d)...)" versus "if ((a !=
b) || (c != d)...)".  There's a pretty small number of functions that
use this trick. In isolating one for testing,  I really don't see the
^ | method as being much of win, even with a modest amount of branch
correct branch prediction || can be better, if we can get mostly
correct branch prediction it can be significantly better. Before I fix
this, is there any background I should know about? :-)

Tom
