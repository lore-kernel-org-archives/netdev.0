From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Fri, 09 Nov 2012 10:31:11 +0800
Message-ID: <509C6AEF.4020300@gmail.com>
References: <1335522818.2775.227.camel@edumazet-glaptop>  <509A19E6.4040707@gmail.com>  <509A1D49.4080306@gmail.com>  <1352286264.3140.3575.camel@edumazet-glaptop>  <509B6368.9010206@gmail.com> <1352381449.19779.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:64981 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756712Ab2KICbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 21:31:16 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so1452379dak.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 18:31:15 -0800 (PST)
In-Reply-To: <1352381449.19779.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B411=E6=9C=8808=E6=97=A5 21:30, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Thu, 2012-11-08 at 15:46 +0800, Li Yu wrote:
>
>> I think that all kmalloced() objects are continuous on both virtual
>> and physical address space, so such page fragment converting should =
be
>> safe until we use slab allocator to free them.
>>
>
> Its not safe at all. Good luck with coping with SLAB, SLUB, SLOB, and
> various debugging facilities on top of them.
>

The slab class API semantic should not change among them. the debugging
facilities should only add or modify metadata around user bytes too.
However, I also decided giving up use kmalloced() objects since it is=20
hard to free them safely them without some extra efforts after doing
page fragmentation on them.

I think that adding skb->frag_head indeed is a better choice, this mean=
s=20
I have to rework some NIC drivers :(

>> I ask this question since I am working on a patch to try to directly
>> forward the data from rx queue of a socket to tx queue of another
>> socket. We noticed that the splice itself still has visible costs wh=
en
>> forwarding small messages, and hope such direct forwarding optimizat=
ion
>> can improve this, this idea comes from TCP friends.
>
> If not using splice, you directly transfert one skb coming from one
> side, to the other side, so you dont care skb->head being a frag or n=
ot.
>
> If messages are small, there is probably no hope trying to coalesce t=
hem
> (or else fixing the application would be much easier)
>

This patch is hoped that can work well for big messages too, so I
selected moving page fragment, and I think this should be easier a bit
because I can directly reuse tcp_sendpage() interface or just need a bi=
t=20
of changes on it :)

If it can work well, I will send it out.

Thans very much for your time, :)

Yu

>
>
>
