From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ixgbe RSS not working as expected with 8021q and bridging
Date: Fri, 11 Dec 2009 01:11:34 +0100
Message-ID: <4B218E36.4030808@gmail.com>
References: <20091210231103.GA20231@esk.cs.usu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46163 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761757AbZLKALf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 19:11:35 -0500
In-Reply-To: <20091210231103.GA20231@esk.cs.usu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/12/2009 00:11, Eldon Koyle a =E9crit :
> We have built a firewall with two 10 Gbit interfaces (intel 82598EB) =
and
> are doing some testing.  A simple bridge between the two interfaces a=
cts
> as expected with packets being distributed fairly evenly across all o=
f
> the rx/tx queues.
>=20
> We then switched to tagged vlans on both interfaces (10 vlans each, 8
> source and 8 dest addresses per vlan) and bridged eth0.N to eth1.N, a=
nd
> many of our queues (and CPUs) remained idle, and all of our VLAN traf=
fic
> went out on the same tx queue.  Are multiple transmit queues supporte=
d
> with 802.1q?  How do we figure out what is causing some of our receiv=
e
> queues to be unused?
>=20
> We are using 2.6.31 (from Debian) and ixgbe-2.0.44.14 .
>=20

You need more recent kernel (2.6.32) to get multi queue support on vlan=
s, sorry.

commit 2f8bc32b7a08502a79e0ccec8697000f2977f2fd
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Sep 3 02:19:58 2009 -0700

    vlan: enable multiqueue xmits

    vlan_dev_hard_start_xmit() & vlan_dev_hwaccel_hard_start_xmit()
    select txqueue number 0, instead of using index provided by
    skb_get_queue_mapping().

    This is not correct after commit 2e59af3dcbdf11635c03f
    [vlan: multiqueue vlan device] because
    txq->tx_packets  & txq->tx_bytes changes are performed on
    a single location, and not the right locking.

    Fix is to take the appropriate struct netdev_queue pointer

    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
