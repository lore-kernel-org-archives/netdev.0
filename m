From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Modify bonding hash transmit policies to use the packet's
 source MAC address
Date: Fri, 23 Oct 2009 14:37:19 +0200
Message-ID: <4AE1A37F.8010203@gmail.com>
References: <20091023114511.GA537@spaans.fox.local> <20091023115834.GA2216@spaans.fox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40950 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbZJWMhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 08:37:19 -0400
In-Reply-To: <20091023115834.GA2216@spaans.fox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jasper Spaans a =E9crit :
> Modify bonding hash transmit policies to use the psource MAC address =
of
> the packet instead of the MAC address configured for the bonding devi=
ce.
>=20
> The old sitation conflicts with the documentation.
> ---
>  drivers/net/bonding/bond_main.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 69c5b15..b140b52 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3668,7 +3668,7 @@ static int bond_xmit_hash_policy_l23(struct sk_=
buff *skb,
>  			(data->h_dest[5] ^ bond_dev->dev_addr[5])) % count;

You forgot one bond_dev->dev_addr[5] occurrence here


>  	}
> =20
> -	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
> +	return (data->h_dest[5] ^ data->h_source[5]) % count;
>  }

Could you check if bond->xmit_hash_policy(skb, bond_dev, bond->slave_cn=
t);
could be replaced by bond->xmit_hash_policy(skb, bond->slave_cnt),
now that various implementations dont need bond_dev anymore ?

static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count) ..=
=2E

Dont forget your "Signed-off-by: Jasper Spaans <spaans@fox-it.com>",
copied to "David S. Miller" <davem@davemloft.net>  and "Jay Vosburgh" <=
fubar@us.ibm.com>
(respectively network and bonding maintainers)

Thanks
