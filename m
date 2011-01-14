From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Sat, 15 Jan 2011 02:12:12 +0300
Message-ID: <4D30D84C.6000801@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <4D30ADB3.7010509@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dinosaur.yandex.ru ([77.88.34.8]:32207 "EHLO dinosaur.yandex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468Ab1ANXMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 18:12:15 -0500
In-Reply-To: <4D30ADB3.7010509@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



John Fastabend wrote:

>=20
> I think you want this patch against net-next not 2.6.37.
This patch is against  2.6.37-git11 and I've tried to apply it to=20
net-next - it applied ok
>=20
> Oleg, sorry but I don't follow. If this is simply sending every next =
packet
> via "next" slave interface how are packets not going to get out of or=
der? If
> the links have different RTT this would seem problematic.
>=20
> Have you considered using multipath at the block layer? This is how I=
 generally
> handle load balancing over iSCSI/FCoE and it works reasonably well.
>=20
> see ./drivers/md/dm-mpath.c

John, the first solution I was using a long time for ISCSI load=20
balancing was multipath. But there are some problems with dm-multipath:
- it is slow(I am using ISCSI for Oracle , so I need to minimize latenc=
y)
- it handles any link failures bad, because of it's command queue=20
limitation(all queued commands above 32 are discarded in case of path=20
failure, as I remember)
- it performs very bad when there are many devices and ma=D1=82y paths(=
I was=20
unable to utilize more that 2Gbps of 4 even with 100 disks with 4 paths=
=20
per each disk)

My patch won't work correct when slave links have different RTT, this i=
s=20
true - it is usable only within one ethernet segment with equal/near=20
equal RTT. This is it's limitation.


>> +static int bond_xmit_hash_policy_rr(struct sk_buff *skb,
>> +				   struct net_device *bond_dev, int count)
>=20
> Here's one reason why this won't work on net-next-2.6.
>=20
> int      (*xmit_hash_policy)(struct sk_buff *, int);

Thank you, I've missed that change.

>=20
>=20
> Thanks,
> John
>=20

--=20
Best reagrds,
Oleg Ukhno
