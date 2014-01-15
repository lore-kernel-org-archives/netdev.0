From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: Aw: Re: Route exceptions for IPv6 routes?
Date: Wed, 15 Jan 2014 13:25:25 +0100 (CET)
Message-ID: <trinity-6d5496d3-c58c-4b56-a0a8-777473467042-1389788725698@3capp-gmx-bs13>
References: <trinity-d0560a1c-2418-449e-b478-ebc707cea8e5-1389772882296@3capp-gmx-bs10>,
 <20140115115115.GD19945@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:60294 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959AbaAOMZ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 07:25:27 -0500
Received: from 3capp-gmx-bs13.server.lan ([172.19.170.65]) by
 mrigmx.server.lan (mrigmx001) with ESMTP (Nemesis) id
 0MgaEb-1VfwjC3UGN-00NzB2 for <netdev@vger.kernel.org>; Wed, 15 Jan 2014
 13:25:25 +0100
In-Reply-To: <20140115115115.GD19945@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hannes,
thanks for the answer.

Sorry, I'm not so familiar with the implementation details.

What are nh-exceptions?

I understand the current IPv6 implementation has some performance drawb=
acks. Correct?

I'm especially interested in=20
a) support for path MTUs
b) IPv6 policy-based routing (can I expect the same results from "ip -6=
 rule" commands that I get from "ip rule" commands?)

Are these basically supported (maybe not with optimal performance) ?

best regards, Simon=C2=A0
=C2=A0

Gesendet:=C2=A0Mittwoch, 15. Januar 2014 um 12:51 Uhr
Von:=C2=A0"Hannes Frederic Sowa" <hannes@stressinduktion.org>
An:=C2=A0"Simon Schneider" <simon-schneider@gmx.net>
Cc:=C2=A0netdev@vger.kernel.org
Betreff:=C2=A0Re: Route exceptions for IPv6 routes?
Hi!

On Wed, Jan 15, 2014 at 09:01:22AM +0100, Simon Schneider wrote:
> I learned that the routing cache was removed from the kernel for seve=
ral reasons.
>
> Some functions have been replaced with the route exceptions, e.g. sto=
ring the path MTU.
>
> My question: is this valid for both IPv4 as well as IPv6 routing, i.e=
=2E do the route exceptions work in the same way for IPv6 routes as the=
y work for IPv4 routes?

No, situation in IPv6 land is not so good.

Currently as soon as a destination (or destination + source in case of
subtrees are in use) is resolved the routing entry is cloned and stored=
 back
into the same trie with RTF_CACHE flag.

There are no nh-exceptions and there is no aggressive sharing taking pl=
ace to
try to reduce the number of exceptions. This is especially bad for forw=
arding
setups, but seems to work fine for most people currently. ;)

Actually, implementing this is part of the work I am currently doing
but this needs still time until I can manage to propose this for upstre=
am.

Greetings,

Hannes

