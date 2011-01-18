From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Tue, 18 Jan 2011 15:54:44 +0100
Message-ID: <4D35A9B4.7030701@gmail.com>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?U8OpYmFz?= =?UTF-8?B?dGllbiBCYXJyw6k=?=
	<sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59443 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab1AROyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 09:54:49 -0500
Received: by wyb28 with SMTP id 28so6204008wyb.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 06:54:48 -0800 (PST)
In-Reply-To: <4D358A47.4020009@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/01/2011 13:40, Oleg V. Ukhno a =C3=A9crit :

The fact that there exist many situations where it simply doesn't work,=
 should not cause the idea of=20
Oleg to be rejected.

In Documentation/networking/bonding.txt, tuning tcp_reordering on recei=
ving side is already=20
documented as a possible workaround for out of order delivery due to lo=
ad balancing of a single TCP=20
session, using mode=3Dbalance-rr.

This might work reasonably well in a pure LAN topology, without any rou=
ter between both ends of the=20
TCP session, even if this is limited to Linux hosts. The uses are not u=
ncommon and not limited to iSCSI:
- between an application server and a database server,
- between members of a cluster, for replication purpose,
- between a server and a backup system,
- ...

Of course, for longer paths, with routers and variable RTT, we would ne=
ed something different=20
(possibly MultiPathTCP: http://datatracker.ietf.org/wg/mptcp/).

I remember a topology (described by Jay, for as far as I remember), whe=
re two hosts were connected=20
through two distinct VLANs. In such topology:
- it is possible to detect path failure using arp monitoring instead of=
 miimon.
- changing the destination MAC address of egress packets are not necess=
ary, because egress path=20
selection force ingress path selection due to the VLAN.

I think the only point is whether we need a new xmit_hash_policy for mo=
de=3D802.3ad or whether=20
mode=3Dbalance-rr could be enough.

Oleg, would you mind trying the above "two VLAN" topology" with mode=3D=
balance-rr and report any=20
results ? For high-availability purpose, it's obviously necessary to se=
tup those VLAN on distinct=20
switches.

	Nicolas


