From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Tue, 18 Jan 2011 18:28:48 +0300
Message-ID: <4D35B1B0.2090905@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:2423 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594Ab1ARP2t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 10:28:49 -0500
In-Reply-To: <4D35A9B4.7030701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2011 05:54 PM, Nicolas de Peslo=C3=BCan wrote:
> Le 18/01/2011 13:40, Oleg V. Ukhno a =C3=A9crit :
>
> The fact that there exist many situations where it simply doesn't wor=
k,
> should not cause the idea of Oleg to be rejected.
>
> In Documentation/networking/bonding.txt, tuning tcp_reordering on
> receiving side is already documented as a possible workaround for out=
 of
> order delivery due to load balancing of a single TCP session, using
> mode=3Dbalance-rr.
>
> This might work reasonably well in a pure LAN topology, without any
> router between both ends of the TCP session, even if this is limited =
to
> Linux hosts. The uses are not uncommon and not limited to iSCSI:
> - between an application server and a database server,
> - between members of a cluster, for replication purpose,
> - between a server and a backup system,
> - ...
Nicolas, thank you for your opinion - this is exactly what I mean -=20
iSCSI is just one particular use case, but there are many cases where=20
this load balancing method will be useful
>
> Of course, for longer paths, with routers and variable RTT, we would
> need something different (possibly MultiPathTCP:
> http://datatracker.ietf.org/wg/mptcp/).
>
> I remember a topology (described by Jay, for as far as I remember),
> where two hosts were connected through two distinct VLANs. In such
> topology:
> - it is possible to detect path failure using arp monitoring instead =
of
> miimon.
> - changing the destination MAC address of egress packets are not
> necessary, because egress path selection force ingress path selection
> due to the VLAN.

In case with two VLANs - yes, this shouldn't be necessary(but needs to=20
be tested, I am not sure), but within one - it is essential for correct=
=20
rx load striping.
>
> I think the only point is whether we need a new xmit_hash_policy for
> mode=3D802.3ad or whether mode=3Dbalance-rr could be enough.
May by, but it seems to me fair enough not to restrict this feature onl=
y=20
to non-LACP aggregate links; dynamic aggregation may be useful(it helps=
=20
to avoid switch misconfiguration(misconfigured slaves on switch side)=20
sometimes without loss of service).
>
> Oleg, would you mind trying the above "two VLAN" topology" with
> mode=3Dbalance-rr and report any results ? For high-availability purp=
ose,
> it's obviously necessary to setup those VLAN on distinct switches.
I'll do it, but it will take some time to setup test environment,=20
several days may be.
You mean following topology:
           switch 1
        /           \
host A                host B
        \  switch 2 /

(i'm sure it will work as desired if each host is connected to each=20
switch with only one slave link, if there are more slaves in each switc=
h=20
- unsure)?
>
> Nicolas
>
>
>


--=20
Best regards,
Oleg Ukhno.
ITO Team Lead,
Yandex LLC.



