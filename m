From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: fix unaligned accesses to network headers
Date: Mon, 18 Feb 2013 17:14:25 +0100
Message-ID: <CACna6ry0DWdnsLv0MLERkg8evYpgzAFvYEJes3Jn71iCPkJVjw@mail.gmail.com>
References: <1361025154-11612-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:39774 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755742Ab3BRQO3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 11:14:29 -0500
Received: by mail-ob0-f175.google.com with SMTP id uz6so5660272obc.20
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 08:14:26 -0800 (PST)
In-Reply-To: <1361025154-11612-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/16 Hauke Mehrtens <hauke@hauke-m.de>:
> Without this patch I get many unaligned access warnings per packet,
> this patches fixes them all. This should improve performance ony some
> systems like mips.
>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index d341090..f9b1bc8 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -301,8 +301,9 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac,=
 struct bgmac_dma_ring *ring,
>                         bgmac_err(bgmac, "Found poisoned packet at sl=
ot %d, DMA issue!\n",
>                                   ring->start);
>                 } else {
> -                       new_skb =3D netdev_alloc_skb(bgmac->net_dev, =
len);
> +                       new_skb =3D netdev_alloc_skb(bgmac->net_dev, =
len + 2);
>                         if (new_skb) {
> +                               skb_reserve(new_skb, 2);

I never understood that code in b44, glad you hit that warnings! ;)

The version with netdev_alloc_skb_ip_align looks much better (no more
magic numbers), b44 should be converted too.

Thanks for your patch!

--=20
Rafa=C5=82
