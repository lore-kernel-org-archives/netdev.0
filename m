From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 8 Jul 2016 11:28:23 -0400
Message-ID: <a8a7d2bc-1206-bcf5-3a15-5958728ff5a7@stressinduktion.org>
References: <577FAFFD.2020306@gmx.de>
 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Toralf_F=c3=b6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39515 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755171AbcGHP2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 11:28:25 -0400
In-Reply-To: <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.07.2016 10:14, Eric Dumazet wrote:
> On Fri, 2016-07-08 at 15:51 +0200, Toralf F=C3=B6rster wrote:
>> I do run a 4.6.3 hardened Gentoo kernel at a commodity i7 server. A
>> DDoS with about 300 MBit/sec over 5 mins resulted an issue for ipv6 =
at
>> that system.
>>
>> The IPv6 monitoring from my ISP told my that the to be monitored
>> services (80, 443, 52222) weren't reachable any longer at ipv6 (at
>> ipv4 there was no issue). Restarting the NIC brought back green ligh=
ts
>> for the services at the ipv6 ports too.
>=20
> Hard to tell without knowing DDOS details, but IPv6 lacks some
> scalability improvements found in IPv4.
>=20
> IPv4 no longer has a routing cache, but IPv6 still has one.

The difference is that routing exceptions are stored in "the" trie
instead of hash tables in the fib nodes. IPv4 limits that by the size o=
f
the hash tables, in IPv6 we grow to ipv6/route/max_size, which is prett=
y
low.

Only redirects and mtu updates could potentially increase its size.
Redirects are limited to the same L2 network, MTU updates must hit the
socket to be acted upon appropriately. All limited to max_size, so I
currently see a major problem in the routing code.

Unfortunately your report has not enough details to pinpoint a specific
problem in the kernel

Bye,
Hannes
