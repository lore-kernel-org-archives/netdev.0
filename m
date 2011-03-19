From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [patch] ftmac100: use resource_size()
Date: Sat, 19 Mar 2011 13:05:46 +0800
Message-ID: <AANLkTimHkwDnzKhWh2fD_-ue0-m-+6evPNz=BQZTOis-@mail.gmail.com>
References: <20110319043915.GB2008@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Po-Yu Chuang <ratbert@faraday-tech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41197 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646Ab1CSFGO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 01:06:14 -0400
In-Reply-To: <20110319043915.GB2008@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

On Sat, Mar 19, 2011 at 12:39 PM, Dan Carpenter <error27@gmail.com> wro=
te:
> The calculation is off-by-one. =C2=A0It should be "end - start + 1". =
=C2=A0This
> patch fixes it to use resource_size() instead. =C2=A0Oddly, the code =
already
> uses resource size correctly a couple lines earlier when it calls
> request_mem_region() for this memory.
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
>
> diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
> index 1d6f4b8..a316619 100644
> --- a/drivers/net/ftmac100.c
> +++ b/drivers/net/ftmac100.c
> @@ -1102,7 +1102,7 @@ static int ftmac100_probe(struct platform_devic=
e *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_req_m=
em;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 priv->base =3D ioremap(res->start, res->end - =
res->start);
> + =C2=A0 =C2=A0 =C2=A0 priv->base =3D ioremap(res->start, resource_si=
ze(res));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!priv->base) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_err(&pdev-=
>dev, "Failed to ioremap ethernet registers\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D -EIO;

Ah, I incautiously missed that line when code review.

Thanks,
Po-Yu Chuang
