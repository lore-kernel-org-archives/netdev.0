From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Fri, 10 Jan 2014 08:47:58 -0800
Message-ID: <CA+mtBx-321n=sHNOmw5ncoZN5dDn5K+QwnTY6oyPLSwKO_bZCg@mail.gmail.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	<1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	<1389332635.31367.91.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:52739 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaAJQsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 11:48:00 -0500
Received: by mail-ie0-f170.google.com with SMTP id tq11so4710124ieb.29
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 08:47:58 -0800 (PST)
In-Reply-To: <1389332635.31367.91.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 9:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-01-09 at 21:38 -0800, Eric Dumazet wrote:
>
>> Hmm... this idea was discussed in the past. I used it when attempting to
>> use a hash table instead of a gro_list last year.
>>
>> Unfortunately this added lot of cycles when rxhash is not provided by
>> hardware, and my tests found it was not a win.
>>
>> Remember : in most cases, gro_list contains one flow, so this test does
>> nothing special but adds overhead.
>
> Additional point : For napi_gro_frag() users, skb->head do not contains
> headers, so flow dissector enters slow path to fetch the headers from
> the fragment, one by one.
>
skb_get_hash is only called for the new skb, we compare against
skb->rxhash for packets on the gro_list. Also, I still intend to
change skb_get_hash to not repeatedly compute the hash when there's no
L4 hash to be found.

>
>
