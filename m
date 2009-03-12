From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: VIA velocity skb leak.
Date: Thu, 12 Mar 2009 06:14:27 +0100
Message-ID: <49B89A33.2030207@cosmosbay.com>
References: <20090312041352.GA6035@redhat.com> <20090311.211706.68465072.davem@davemloft.net> <20090311.212009.51140677.davem@davemloft.net> <20090312043954.GA7132@redhat.com> <49B89385.4090005@cosmosbay.com> <20090312045657.GB7132@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57713 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbZCLFPK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 01:15:10 -0400
In-Reply-To: <20090312045657.GB7132@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones a =E9crit :
> On Thu, Mar 12, 2009 at 05:45:57AM +0100, Eric Dumazet wrote:
>=20
>  > > @@ -1845,10 +1846,11 @@ static void velocity_free_tx_buf(struct =
velocity_info *vptr, struct velocity_td_
>  > >  	if (tdinfo->skb_dma) {
>  > > =20
>  > > +		pktlen =3D (skb->len > ETH_ZLEN ? : ETH_ZLEN);
>  >=20
>  > I personally find better to use max(skb->len, ETH_ZLEN) macro, but=
 YMMV ;)
>  >=20
>  > It actually can avoid you a bug ;)
> =20
> I prefer that too, but it makes a warning.
>=20
> drivers/net/via-velocity.c:2093: warning: comparison of distinct poin=
ter types lacks a cast
>=20
> We can fix this by either casting ETH_ZLEN to an unsigned int,
> or we could just do the diff below..
>=20
> Or did I overlook something?
>=20
> (if this looks ok, perhaps the other defines could use the same treat=
ment?)
>=20
> 	Dave
>=20
> The minimum frame length is never signed, define it as
> such so we don't need excessive casts in comparisons.
>=20
> Signed-off-by: Dave Jones <davej@redhat.com>
>=20
> diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
> index 7f3c735..c41183e 100644
> --- a/include/linux/if_ether.h
> +++ b/include/linux/if_ether.h
> @@ -30,7 +30,7 @@
> =20
>  #define ETH_ALEN	6		/* Octets in one ethernet addr	 */
>  #define ETH_HLEN	14		/* Total octets in header.	 */
> -#define ETH_ZLEN	60		/* Min. octets in frame sans FCS */
> +#define ETH_ZLEN	60U		/* Min. octets in frame sans FCS */
>  #define ETH_DATA_LEN	1500		/* Max. octets in payload	 */
>  #define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
>  #define ETH_FCS_LEN	4		/* Octets in the FCS		 */
>=20

or use max_t(unsigned, skb->len, ETH_ZLEN)

