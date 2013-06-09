From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: Fix warnings on 64-bit.
Date: Mon, 10 Jun 2013 02:36:07 +0400
Message-ID: <51B50357.1090500@cogentembedded.com>
References: <20130607.234116.2160936577356433396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:50620 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3FIWgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jun 2013 18:36:10 -0400
Received: by mail-lb0-f176.google.com with SMTP id z5so5649529lbh.21
        for <netdev@vger.kernel.org>; Sun, 09 Jun 2013 15:36:08 -0700 (PDT)
In-Reply-To: <20130607.234116.2160936577356433396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/08/2013 10:41 AM, David Miller wrote:

> Don't cast a plain integer to a pointer.

> drivers/net/ethernet/renesas/sh_eth.c: In function =A1sh_eth_chip_res=
et_giga=A2:
> drivers/net/ethernet/renesas/sh_eth.c:482:22: warning: cast to pointe=
r from integer of different size [-Wint-to-pointer-cast]
> drivers/net/ethernet/renesas/sh_eth.c:483:22: warning: cast to pointe=
r from integer of different size [-Wint-to-pointer-cast]
> drivers/net/ethernet/renesas/sh_eth.c:492:22: warning: cast to pointe=
r from integer of different size [-Wint-to-pointer-cast]
> drivers/net/ethernet/renesas/sh_eth.c:493:22: warning: cast to pointe=
r from integer of different size [-Wint-to-pointer-cast]

> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

> Applied to net-next.

>   drivers/net/ethernet/renesas/sh_eth.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethe=
rnet/renesas/sh_eth.c
> index cff6971..43d8490 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -469,7 +469,7 @@ static struct sh_eth_cpu_data sh7757_data =3D {
>   	.rpadir_value   =3D 2 << 16,
>   };
>
> -#define SH_GIGA_ETH_BASE	0xfee00000
> +#define SH_GIGA_ETH_BASE	0xfee00000UL
>   #define GIGA_MALR(port)		(SH_GIGA_ETH_BASE + 0x800 * (port) + 0x05c=
8)
>   #define GIGA_MAHR(port)		(SH_GIGA_ETH_BASE + 0x800 * (port) + 0x05c=
0)
>   static void sh_eth_chip_reset_giga(struct net_device *ndev)

    Fixing up another dirty hack? This driver is just an abomination...=
 :-)

WBR, Sergei
