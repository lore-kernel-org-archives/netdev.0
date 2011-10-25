From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/9] Cleanup and extension of netdev features
Date: Tue, 25 Oct 2011 05:35:54 +0200
Message-ID: <1319513754.3834.4.camel@edumazet-laptop>
References: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58248 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241Ab1JYDgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 23:36:00 -0400
Received: by wwe6 with SMTP id 6so112501wwe.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 20:35:59 -0700 (PDT)
In-Reply-To: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 octobre 2011 =C3=A0 02:36 +0200, Micha=C5=82 Miros=C5=82aw =
a =C3=A9crit :
> Commit fd38f734 (igbvf: convert to ndo_fix_features) removed last use
> of old ethtool ops for controlling netdevice's features. This series
> finishes the cleanup and extends feature pool to 64 bits.
>=20
> Also, there's additional patch that removes NETIF_F_NO_CSUM as it is
> now, and has been for some time, equivalent to NETIF_F_HW_CSUM.
>=20
> To see the new features in action, you need ethtool patched with:
>=20
> http://patchwork.ozlabs.org/patch/96374/
>=20
> Not much has changed in those patches compared to last version I post=
ed
> in June.

Hi Michal

This reminds me current net-next is busted for bond/vlan, I dont know
why.



$ cat /proc/net/bonding/bond0=20
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: 00:1e:0b:ec:d3:d2
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:1e:0b:92:78:50
Slave queue ID: 0

$ ethtool -k eth1
Offload parameters for eth1:
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
receive-hashing: on


$ ethtool -k eth2
Offload parameters for eth2:
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


$ ethtool -k bond0
Offload parameters for bond0:
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



$ ip link show dev vlan.103
7: vlan.103@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast state UP qlen 100
    link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff


But :

$ ethtool -k vlan.103
Offload parameters for vlan.103:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: off
tx-vlan-offload: off
ntuple-filters: off
receive-hashing: off

So basically all features but GRO are off.
