From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] xilinx:Remove unused variable num_frag in the function
 axienet_start_xmit
Date: Wed, 17 Jun 2015 09:07:30 -0700
Message-ID: <20150617160730.GE2906@xsjsorenbubuntu>
References: <1434556362-3748-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <anirudh@xilinx.com>, <John.Linn@xilinx.com>,
	<michal.simek@xilinx.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0078.outbound.protection.outlook.com ([157.56.110.78]:39139
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757180AbbFQQHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 12:07:49 -0400
Content-Disposition: inline
In-Reply-To: <1434556362-3748-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-17 at 11:52AM -0400, Nicholas Krause wrote:
> This removes the unused variable num_frag and the setting of it
> to the number of fragments from the passed sk_buff pointer by
> this function's caller due to this variable never being used
> in this particular function and is not declared as  global so
> setting it for global use in this file is pointless.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 2 --
>  1 file changed, 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/driv=
ers/net/ethernet/xilinx/xilinx_axienet_main.c
> index 28b7e7d..624dce4 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -651,7 +651,6 @@ static inline int axienet_check_tx_bd_space(struc=
t axienet_local *lp,
>  static int axienet_start_xmit(struct sk_buff *skb, struct net_device=
 *ndev)
>  {
>  	u32 ii;
> -	u32 num_frag;
>  	u32 csum_start_off;
>  	u32 csum_index_off;
>  	skb_frag_t *frag;
> @@ -659,7 +658,6 @@ static int axienet_start_xmit(struct sk_buff *skb=
, struct net_device *ndev)
>  	struct axienet_local *lp =3D netdev_priv(ndev);
>  	struct axidma_bd *cur_p;
> =20
> -	num_frag =3D skb_shinfo(skb)->nr_frags;
>  	cur_p =3D &lp->tx_bd_v[lp->tx_bd_tail];
> =20
>  	if (axienet_check_tx_bd_space(lp, num_frag)) {

It's used right here, isn't it (and further down in this function too)?
Does your tree compile with this change?

	S=C3=B6ren
