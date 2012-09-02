From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/2] ipv4: Improve the scaling of the ARP cache for multicast
 destinations.
Date: Sun, 02 Sep 2012 15:26:03 +0200
Message-ID: <50435E6B.5040007@gmail.com>
References: <50400B68.3060302@aristanetworks.com> <20120830.210628.365120808137655227.davem@davemloft.net> <50410EB8.3040603@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Bob Gilligan <gilligan@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37208 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab2IBNYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 09:24:46 -0400
Received: by eekc1 with SMTP id c1so1683531eek.19
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 06:24:45 -0700 (PDT)
In-Reply-To: <50410EB8.3040603@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 31/08/2012 21:21, Bob Gilligan a =E9crit :
> On 8/30/12 6:06 PM, David Miller wrote:
>> From: Bob Gilligan<gilligan@aristanetworks.com>
>> Date: Thu, 30 Aug 2012 17:55:04 -0700
>>
>>> The mapping from multicast IPv4 address to MAC address can just as
>>> easily be done at the time a packet is to be sent.  With this chang=
e,
>>> we maintain one ARP cache entry for each interface that has at leas=
t
>>> one multicast group member.  All routes to IPv4 multicast destinati=
ons
>>> via a particular interface use the same ARP cache entry.  This entr=
y
>>> does not store the MAC address to use.  Instead, packets for multic=
ast
>>> destinations go to a new output function that maps the destination
>>> IPv4 multicast address into the MAC address and forms the MAC heade=
r.
>>
>> Doing an ARP MC mapping on every packet is much more expensive than
>> doing a copy of the hard header cache.
>>
>> I do not believe the memory consumption issue you use to justify thi=
s
>> change is a real issue.

My two cents:

Why do we need a per interface neighbor cache for multicast? Isn't the =
target MAC expected to be the=20
same for a give target multicast IP address, whatever the egress interf=
ace?

Can't we store the target MAC for multicast address on a neighbor cache=
 entry with a fake dev value=20
meaning "multicast"?

Can't we detect the fact that the IP destination address is multicast a=
nd search only the neighbor=20
cache entries that have this fake dev value, instead of the egress inte=
rface?

This should reduce memory consumption (not N-squared anymore) without s=
ignificantly increasing the=20
CPU usage.

Do I miss something?

	Nicolas.
