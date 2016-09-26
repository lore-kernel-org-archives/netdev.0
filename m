From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: trivial: fix fsl fec_main mdio write return value
Date: Tue, 27 Sep 2016 01:10:14 +0300
Message-ID: <7f2ef23b-7354-2049-9747-cdaf4109b5a0@cogentembedded.com>
References: <20160926191140.12107-1-albert.aribaud@3adev.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <trivial@kernel.org>, Fugang Duan <fugang.duan@nxp.com>
To: "Albert ARIBAUD (3ADEV)" <albert.aribaud@3adev.fr>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33469 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936146AbcIZWKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 18:10:23 -0400
Received: by mail-lf0-f45.google.com with SMTP id b71so135262130lfg.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 15:10:22 -0700 (PDT)
In-Reply-To: <20160926191140.12107-1-albert.aribaud@3adev.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/26/2016 10:11 PM, Albert ARIBAUD (3ADEV) wrote:

> If the MDIO enf-of-transfer wait loop does not time out,
> 0 should be returned to the caller through ret, but ret
> was not reset to 0 after receiving the return value of
> pm_runtime_get_sync(). Reset ret when no time out occurred.
>
> Signed-off-by: Albert ARIBAUD (3ADEV) <albert.aribaud@3adev.fr>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 01f7e81..0413c05 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1818,6 +1818,8 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
>  		netdev_err(fep->netdev, "MDIO write timeout\n");
>  		ret  = -ETIMEDOUT;
>  	}
> +	else

	} else {

> +		ret = 0;

	}

[...]

MBR, Sergei
