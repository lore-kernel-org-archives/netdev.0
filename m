From: Brian Haley <brian.haley@hp.com>
Subject: Re: Why MLDv2 Report packet is freed ?
Date: Wed, 16 Apr 2008 14:02:59 -0400
Message-ID: <48063F53.4030102@hp.com>
References: <d0383f90804150623r2eb071fau200a67c6ce65a7e0@mail.gmail.com>	 <20080415.234844.99535411.yoshfuji@linux-ipv6.org> <d0383f90804160450x31e1577en60d4a6cca29a00ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Ian Brown <ianbrn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:23778 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbYDPSAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 14:00:23 -0400
In-Reply-To: <d0383f90804160450x31e1577en60d4a6cca29a00ca@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Brown wrote:
> Hello,
> 
> I am sorry, I tried to delve into the code and I not sure I can figure out this
> point.
>> MLD packets are handled in other place.
> 
> Can anybody please try to elaborate on this point: how
> are MLD packets handled ? Shouldn't MLD packets be
> handled by pim6sd daemon?

Yes.

> I see handlers for accepting MLD (v1 and v2)
> in pim6sd daemon;
> And in case MLD packets  should be handled by pim6sd  - shouldn't the kernel
> pass these MLD packets to the pim6sd daemon (by calling sock_queue_rcv_skb()
> in ip6mr.c) ? As far as I can understand, these MLD packets are
> dropped in icmpv6_rcv()

>From what I can tell, ip6_mc_input() makes a copy if multicast routing
is enabled.  Those copies eventually get to ip6mr_cache_report() which
delivers them to user-space (there's even a reference to pim6sd in
net/ipv6/ip6mr.c).

Have you seen them not get delivered?

-Brian
