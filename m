From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] p54: memset(0) whole array
Date: Sat, 15 Oct 2016 08:04:51 +0200
Message-ID: <6511335.zy53ITykIM@debian64>
References: <20161014092309.24113-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33606 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbcJOGEz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 02:04:55 -0400
In-Reply-To: <20161014092309.24113-1-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, October 14, 2016 11:23:09 AM CEST Jiri Slaby wrote:
> gcc 7 complains:
> drivers/net/wireless/intersil/p54/fwio.c: In function 'p54_scan':
> drivers/net/wireless/intersil/p54/fwio.c:491:4: warning: 'memset' used with length equal to number of elements without multiplication by element size [-Wmemset-elt-size]
> 
> Fix that by passing the correct size to memset.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Christian Lamparter <chunkeey@googlemail.com>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
Acked-by: Christian Lamparter <chunkeey@googlemail.com>
> ---
>  drivers/net/wireless/intersil/p54/fwio.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/intersil/p54/fwio.c b/drivers/net/wireless/intersil/p54/fwio.c
> index 257a9eadd595..4ac6764f4897 100644
> --- a/drivers/net/wireless/intersil/p54/fwio.c
> +++ b/drivers/net/wireless/intersil/p54/fwio.c
> @@ -488,7 +488,7 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
>  
>  			entry += sizeof(__le16);
>  			chan->pa_points_per_curve = 8;
> -			memset(chan->curve_data, 0, sizeof(*chan->curve_data));
> +			memset(chan->curve_data, 0, sizeof(chan->curve_data));
>  			memcpy(chan->curve_data, entry,
>  			       sizeof(struct p54_pa_curve_data_sample) *
>  			       min((u8)8, curve_data->points_per_channel));
> 
