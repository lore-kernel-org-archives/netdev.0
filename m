From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: wimax: i2400m: i2400m-usb: Use
 time_after for time comparison
Date: Mon, 08 May 2017 17:26:18 -0400 (EDT)
Message-ID: <20170508.172618.676839687841750049.davem@davemloft.net>
References: <1494262682-5401-1-git-send-email-karim.eshapa@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: karim.eshapa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdEHV0W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 17:26:22 -0400
In-Reply-To: <1494262682-5401-1-git-send-email-karim.eshapa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karim Eshapa <karim.eshapa@gmail.com>
Date: Mon,  8 May 2017 18:58:02 +0200

> diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
> index 649ecad..6fc941c 100644
> --- a/drivers/net/wimax/i2400m/i2400m-usb.h
> +++ b/drivers/net/wimax/i2400m/i2400m-usb.h
> @@ -131,7 +131,7 @@ static inline int edc_inc(struct edc *edc, u16 max_err, u16 timeframe)
>  	unsigned long now;
>  
>  	now = jiffies;
> -	if (now - edc->timestart > timeframe) {
> +	if (time_after(now - edc->timestart, (unsigned long)timeframe)) {

This is far from correct.

time_after() compares two "jiffies" timestamp values.  The second
argument here is not a jiffies timestamp value.
