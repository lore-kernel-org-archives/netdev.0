From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] hso: add missing last_rx setting
Date: Tue, 09 Jun 2009 16:37:26 +0200
Message-ID: <4A2E73A6.5070708@gmail.com>
References: <20090604155019.6660.33231.stgit@Programuotojas> <20090604.154204.163892378.davem@davemloft.net> <4A2E6C31.2070402@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, j.dumon@option.com,
	netdev@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56162 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757897AbZFIOhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 10:37:51 -0400
In-Reply-To: <4A2E6C31.2070402@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paulius Zaleckas a =E9crit :
> David Miller wrote:
>> From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
>> Date: Thu, 04 Jun 2009 18:50:23 +0300
>>
>>> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
>> The core networking does this now for the drivers, they
>> don't need to do it themselves any longer.
>=20
> Where? I couldn't find it even in net-next...

vi +1937 include/linux/netdevice.h

/* On bonding slaves other than the currently active slave, suppress
 * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
 * ARP on active-backup slaves with arp_validate enabled.
 */
static inline int skb_bond_should_drop(struct sk_buff *skb)
{
        struct net_device *dev =3D skb->dev;
        struct net_device *master =3D dev->master;

        if (master) {
                if (master->priv_flags & IFF_MASTER_ARPMON)
                        dev->last_rx =3D jiffies;

=2E..



commit 6cf3f41e6c08bca6641a695449791c38a25f35ff
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Mon Nov 3 18:16:50 2008 -0800

    bonding, net: Move last_rx update into bonding recv logic

        The only user of the net_device->last_rx field is bonding.
    This patch adds a conditional update of last_rx to the bonding spec=
ial
    logic in skb_bond_should_drop, causing last_rx to only be updated w=
hen
    the ARP monitor is running.

        This frees network device drivers from the necessity of
    updating last_rx, which can have cache line thrash issues.

    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
