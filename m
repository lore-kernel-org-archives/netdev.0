From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v2] xen: netback: fix printf format string warning
Date: Mon, 1 Jun 2015 12:23:47 +0100
Message-ID: <20150601112347.GA19403@zion.uk.xensource.com>
References: <1433154604-27997-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26693 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461AbbFALXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 07:23:50 -0400
Content-Disposition: inline
In-Reply-To: <1433154604-27997-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 01, 2015 at 11:30:04AM +0100, Ian Campbell wrote:
> drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_bui=
ld_gops=E2=80=99:
> drivers/net/xen-netback/netback.c:1253:8: warning: format =E2=80=98%l=
u=E2=80=99 expects argument of type =E2=80=98long unsigned int=E2=80=99=
, but argument 5 has type =E2=80=98int=E2=80=99 [-Wformat=3D]
>         (txreq.offset&~PAGE_MASK) + txreq.size);
>         ^
>=20
> PAGE_MASK's type can vary by arch, so a cast is needed.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ----
> v2: Cast to unsigned long, since PAGE_MASK can vary by arch.
> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netb=
ack/netback.c
> index 4de46aa..0d25943 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1250,7 +1250,7 @@ static void xenvif_tx_build_gops(struct xenvif_=
queue *queue,
>  			netdev_err(queue->vif->dev,
>  				   "txreq.offset: %x, size: %u, end: %lu\n",
>  				   txreq.offset, txreq.size,
> -				   (txreq.offset&~PAGE_MASK) + txreq.size);
> +				   (unsigned long)(txreq.offset&~PAGE_MASK) + txreq.size);
>  			xenvif_fatal_tx_err(queue->vif);
>  			break;
>  		}
> --=20
> 1.7.10.4
