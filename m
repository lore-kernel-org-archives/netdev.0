From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] bcm43xx-softmac: Further improvement in wireless
	statistics
Date: Tue, 11 Jul 2006 15:32:50 -0400
Message-ID: <1152646370.27683.2.camel@localhost.localdomain>
References: <44B3CC25.7060305@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34262 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751207AbWGKTcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 15:32:48 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44B3CC25.7060305@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-11 at 11:04 -0500, Larry Finger wrote:
> This minor patch adjusts the parameters of the wireless statistics to improve the display of 
> programs such as the "Wireless Network Information" applet of KDE.
> 
> Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>
> 
> ==============================================================
> 
> 
> 
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> index 8ffd760..1ea04da 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> @@ -49,7 +49,7 @@ #define BCM43xx_WX_VERSION	18
>   #define MAX_WX_STRING		80
>   /* FIXME: the next line is a guess as to what the maximum value of RX power
>             (in dBm) might be */
> -#define RX_POWER_MAX		-10
> +#define RX_POWER_MAX		-20
> 
> 
>   static int bcm43xx_wx_get_name(struct net_device *net_dev,
> @@ -231,8 +231,8 @@ static int bcm43xx_wx_get_rangeparams(st
> 
>   	range->max_qual.qual = 100;
>   	/* TODO: Real max RSSI */
> -	range->max_qual.level = 0;
> -	range->max_qual.noise = 0;
> +	range->max_qual.level = -100;
> +	range->max_qual.noise = -100;
>   	range->max_qual.updated = IW_QUAL_ALL_UPDATED;

NAK... remember, range->max_qual.level must be _0_ if you're in dBm,
since 0 is the actual maximum, and your level values are negative since
they are in dBm.

If KDE network applets display the wrong value when max_qual.level == 0,
then they are wrong and need to be fixed.

If you actually want RSSI, then you set max_qual.level to the upper
limit of your RSSI, and the RSSI is assumed to go from 0 ->
max_qual.level.  AFAIK, the patch you had earlier is using dBm, _not_
RSSI, so max_qual.level = 0 is correct.

Dan

>   	range->avg_qual.qual = 50;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

