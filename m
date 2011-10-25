From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/9] Cleanup and extension of netdev features
Date: Tue, 25 Oct 2011 05:44:56 +0200
Message-ID: <1319514296.3834.6.camel@edumazet-laptop>
References: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
	 <1319513754.3834.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57896 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278Ab1JYDpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 23:45:00 -0400
Received: by wyg36 with SMTP id 36so55525wyg.19
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 20:44:59 -0700 (PDT)
In-Reply-To: <1319513754.3834.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 octobre 2011 =C3=A0 05:35 +0200, Eric Dumazet a =C3=A9crit =
:

>=20
> $ ip link show dev vlan.103
> 7: vlan.103@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
> pfifo_fast state UP qlen 100
>     link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff
>=20
>=20
> But :
>=20
> $ ethtool -k vlan.103
> Offload parameters for vlan.103:
> rx-checksumming: off
> tx-checksumming: off
> scatter-gather: off
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: off
> tx-vlan-offload: off
> ntuple-filters: off
> receive-hashing: off
>=20
> So basically all features but GRO are off.
>=20
>=20

By the way If I use vlan on top of nic, it seems OK, so bonding is the
suspect ?

$ ip link add link eth3 eth3.103 type vlan id 103
$ ifconfig eth3.103 up
$ ethtool -k eth3.103
Offload parameters for eth3.103:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off
