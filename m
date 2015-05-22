From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net,stable-4.0] cdc_ncm: Fix tx_bytes statistics
Date: Fri, 22 May 2015 18:22:47 +0100
Message-ID: <1432315367.22824.19.camel@codethink.co.uk>
References: <1432293322-11928-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Bruhin <me@the-compiler.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:38332 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757541AbbEVRWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 13:22:53 -0400
In-Reply-To: <1432293322-11928-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-22 at 13:15 +0200, Bj=C3=B8rn Mork wrote:
> The tx_curr_frame_payload field is u32. When we try to calculate a
> small negative delta based on it, we end up with a positive integer
> close to 2^32 instead.  So the tx_bytes pointer increases by about
> 2^32 for every transmitted frame.
>=20
> Fix by calculating the delta as a signed long.

Told you I hadn't tested it.

Ben.

> Cc: Ben Hutchings <ben.hutchings@codethink.co.uk>
> Reported-by: Florian Bruhin <me@the-compiler.org>
> Fixes: 7a1e890e2168 ("usbnet: Fix tx_bytes statistic running backward=
 in cdc_ncm")
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
>  drivers/net/usb/cdc_ncm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index c3e4da9e79ca..8067b8fbb0ee 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -1182,7 +1182,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struc=
t sk_buff *skb, __le32 sign)
>  	 * payload data instead.
>  	 */
>  	usbnet_set_skb_tx_stats(skb_out, n,
> -				ctx->tx_curr_frame_payload - skb_out->len);
> +				(long)ctx->tx_curr_frame_payload - skb_out->len);
> =20
>  	return skb_out;
> =20
