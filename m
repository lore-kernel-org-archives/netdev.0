From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [patch] atm: forever loop loading ambassador firmware
Date: Wed, 28 Nov 2012 10:40:44 -0500
Message-ID: <20121128104044.785f1041@thirdoffive.cmf.nrl.navy.mil>
References: <20121127172935.GB1059@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:35631 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab2K1Pl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 10:41:59 -0500
In-Reply-To: <20121127172935.GB1059@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Nov 2012 20:29:35 +0300
Dan Carpenter <dan.carpenter@oracle.com> wrote:

> There was a forever loop introduced here when we converted this to
> request_firmware() back in 2008.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

This certainly does seem to be the case.

Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>

> ---
> Spotted in code reading.  Untested.
> 
> diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
> index 89b30f3..ff7bb8a 100644
> --- a/drivers/atm/ambassador.c
> +++ b/drivers/atm/ambassador.c
> @@ -1961,6 +1961,7 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
>      res = loader_verify(lb, dev, rec);
>      if (res)
>        break;
> +    rec = ihex_next_binrec(rec);
>    }
>    release_firmware(fw);
>    if (!res)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
