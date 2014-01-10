From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Fri, 10 Jan 2014 08:27:20 -0800
Message-ID: <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	<1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:45210 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbaAJQ1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 11:27:20 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so5226833iec.5
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 08:27:20 -0800 (PST)
In-Reply-To: <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 9:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-01-09 at 20:54 -0800, Tom Herbert wrote:
>> When initializing a gro_list for a packet, first check the rxhash of
>> the incoming skb against that of the skb's in the list. This should be
>> a very strong inidicator of whether the flow is going to be matched,
>> and potentially allows a lot of other checks to be short circuited.
>>
>
> Hmm... this idea was discussed in the past. I used it when attempting to
> use a hash table instead of a gro_list last year.
>
> Unfortunately this added lot of cycles when rxhash is not provided by
> hardware, and my tests found it was not a win.
>
> Remember : in most cases, gro_list contains one flow, so this test does
> nothing special but adds overhead.

I don't understand what your basis is that gro_list in most cases
contains one flow, but assuming that were true, maybe we should make
the it only contain one flow eliminating the complexity of multiple
flows (same_flow logic is convoluted and layers of encapsulation is
not going to simplify things).

If we are doing RPS or RFS, rxhash will be computed anyway, so the
case your optimizing is pretty narrow: no RPS, no RFS, no hardware
hash, and a single flow in gro_list. Nevertheless, if this is really
an important concern, we can make the check directly against
skb->rxhash so to be opportunistic and avoid the possibility of
computation.

>
>
>
