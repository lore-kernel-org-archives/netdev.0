From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen: netback: fix error printf format string.
Date: Fri, 29 May 2015 17:24:52 +0100
Message-ID: <20150529162452.GH30474@zion.uk.xensource.com>
References: <1432916524-20881-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:33395 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030220AbbE2QY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 12:24:56 -0400
Content-Disposition: inline
In-Reply-To: <1432916524-20881-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 05:22:04PM +0100, Ian Campbell wrote:
> drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_bui=
ld_gops=E2=80=99:
> drivers/net/xen-netback/netback.c:1253:8: warning: format =E2=80=98%l=
u=E2=80=99 expects argument of type =E2=80=98long unsigned int=E2=80=99=
, but argument 5 has type =E2=80=98int=E2=80=99 [-Wformat=3D]
>         (txreq.offset&~PAGE_MASK) + txreq.size);
>         ^
>=20
> txreq.offset and .size are uint16_t fields.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netb=
ack/netback.c
> index 4de46aa..a3b1cbb 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1248,7 +1248,7 @@ static void xenvif_tx_build_gops(struct xenvif_=
queue *queue,
>  		/* No crossing a page as the payload mustn't fragment. */
>  		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
>  			netdev_err(queue->vif->dev,
> -				   "txreq.offset: %x, size: %u, end: %lu\n",
> +				   "txreq.offset: %x, size: %u, end: %u\n",
>  				   txreq.offset, txreq.size,
>  				   (txreq.offset&~PAGE_MASK) + txreq.size);
>  			xenvif_fatal_tx_err(queue->vif);
> --=20
> 1.7.10.4
