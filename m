From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Wed, 07 Aug 2013 17:07:47 -0700
Message-ID: <5202E153.4060202@candelatech.com>
References: <51F15E50.8080208@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Vitaly E. Lavrov" <lve@guap.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59836 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933213Ab3HHAH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 20:07:58 -0400
In-Reply-To: <51F15E50.8080208@guap.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2013 10:20 AM, Vitaly E. Lavrov wrote:
> The network device VETH can't support the feature NETIF_F_HW_CSUM.
> All locally generated packets have invalid checksum.
> Wrong commit http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8093315a91340bca52549044975d8c7f673b28a1 ( kernel 3.9.0 )
>
> Workaround "ethtool -K vethX tx off"
>
> Possible patch:
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 177f911..3db97da 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -254,7 +254,7 @@ static const struct net_device_ops veth_netdev_ops = {
>   };
>
>   #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
> -                      NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
> +                      NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
>                         NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | \
>                         NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_STAG_RX )

I see the same problem.

My test case is a bit complicated, but the gist is that I have a VETH
pair, one with IP (veth1), one connected to a bridge-like-thing (veth2).

The UDP frames sent on veth1 appear on veth2, and when I sniff veth2,
the packets show broken checksum.  The work-around mentioned in Vitaly's
email above fixes the problem for me (I did not try the patch yet).

Eric:  You responded originally that you needed more info.  If
my explanation above is not sufficient, please let me know what
you need...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
