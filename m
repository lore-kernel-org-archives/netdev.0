From: Patrick McHardy <kaber@trash.net>
Subject: Re: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 13:29:25 +0100
Message-ID: <474C0DA5.3030004@trash.net>
References: <636518.43765.qm@web51402.mail.re2.yahoo.com> <20071127115849.GA3427@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joerg Pommnitz <pommnitz@yahoo.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56972 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbXK0M3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 07:29:33 -0500
In-Reply-To: <20071127115849.GA3427@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Tue, Nov 27, 2007 at 02:54:10AM -0800, Joerg Pommnitz wrote:
>> Jarek,
>> this is all about outgoing packets, e.g. egress to use your word.
>> It doesn't matter whether the packets are originated locally or
>> whether the packets are forwarded from another host (I tried
>> both).
>>
>> To restate the problem: according to my observations the prio qdisc
>> (and probably pfifo_fast, but I couldn't observe this) does not prio=
ritize
>> at all and always uses the band indicated by the first entry in the
>> priomap.
>>
>> By default the priomap looks like this:
>> qdisc prio 1: dev eth1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 =
1 1
>>
>> there are 3 bands (1:1, 1:2 and 1:3). In theory the traffic should g=
o through
>> the different bands according to the TOS value of the packets. My ob=
servation
>> is, that the traffic always uses the band pointed to by the first en=
try in the
>> priomap. This value is 1 by default, so all traffic goes through ban=
d 1:2.
>>
>> Now it's entirely possible that I did something stupid, but nobody c=
ame forward
>> to show me the error of my ways (neither here nor on the lartc list)=
=2E
>>
>=20
> I don't think there could be anything stupid if something is maybe no=
t
> enough documented. But, this really should work - just like you've
> found: TOS should be recalculated to skb->priority, and this should
> affect prio. You should only consider that this recalculation isn't
> done for all packets, but only forwarded ones (if I can remember, did=
n't
> miss something, and nothing changed later...). So, are you still sure
> you've tested such a case? (Btw., there are some other tools which ca=
n
> change this priority field, so I hope you don't use them too.)


It works fine here, I'm guessing that J=F6rg is using an old kernel
version that had a bug in prio classification without filters.
