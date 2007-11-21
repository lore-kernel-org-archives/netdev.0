From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv6 0/3] Interface group patches
Date: Wed, 21 Nov 2007 01:25:54 +0100
Message-ID: <47437B12.9090009@trash.net>
References: <11955644701165-git-send-email-panther@balabit.hu>	<Pine.LNX.4.64.0711201425530.32378@fbirervta.pbzchgretzou.qr>	<4742E68C.2000802@balabit.hu> <20071120.134242.177093096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: panther@balabit.hu, jengelh@computergmbh.de,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47281 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbXKUA0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 19:26:01 -0500
In-Reply-To: <20071120.134242.177093096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Laszlo Attila Toth <panther@balabit.hu>
> Date: Tue, 20 Nov 2007 14:52:12 +0100
>=20
>> Jan Engelhardt =EDrta:
>>> On Nov 20 2007 14:14, Laszlo Attila Toth wrote:
>>>> This is the 6th version of our interface group patches.
>>>>
>>>> The interface group value can be used to manage different interfac=
es
>>>> at the same time such as in netfilter/iptables.
>>> I take it you could not use...?
>>> 	iptables -i iif1 -j dosomething
>>> 	iptables -i iif2 -j dosomething
>> This kind of usage requires static interface names. But there are=20
>> dynamic interfaces such as ppp, where the actual name is not always=20
>> known or sometimes they exist sometimes not. It is difficult to use=20
>> iptables this way, and every ifup/ifdown requires change in the ipta=
bles=20
>> ruleset (donwload it, modify and upload to the kernel). It may be to=
o slow.
>=20
> This is actually not true these days.
>=20
> When network devices are created user events are generated and the
> user can rename the device however they like using a mapping table of
> any kind.
>=20
> And at such point the problem you present doesn't actually exist, you
> can know what the device will be named.
>=20
> And if rule loading dynamically is slow, we should fix that instead o=
f
> creating infrastructure and interfaces we don't actually need.


I actually like this feature. Matching on names in iptables
has always been one of the major bottlenecks, taking
(according to my last measurement, which is some time ago)
about 1-2% of the total performance. This is of course in
large parts because the interface match is present on *every*
rule, but still some way to logically group interfaces seems
useful to me, not only for iptables, but also for routing rules,
traffic classifiers, af_packet sockets etc.

I'm working on the incremental ruleset changing API BTW :)
One of the changes will be that interface matching is not
a default part of every rule, and without wildcards it will
use the ifindex. But since the cost of this feature seems
pretty low, I don't see a compelling reason against it.

