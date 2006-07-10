From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx-d80211: Fix an off-by-one condition in handle_irq_noise
Date: Tue, 11 Jul 2006 01:02:52 +0200
Message-ID: <200607110102.52444.mb@bu3sch.de>
References: <44B2DB2F.9090602@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:59087
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965055AbWGJXBC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 19:01:02 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44B2DB2F.9090602@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 11 July 2006 00:56, you wrote:
> An assert statement near the start of handle_irq_noise in the d80211 version of bcm43xx_main.c is 
> there to protect against out of bound addressing using variable bcm->noisecalc.nr_samples. The 
> arrays in question have a dimension of 8, thus the value must be < 8. This patch mirrors the one 
> submitted earlier for the softmac version of bcm43xx.
> 
> Signed-Off-By: Larry.Finger <Larry.Finger@lwfinger.net>
> 
> ========================================================
> 
> index 7ed18ca..37bb0dd 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c

This is not a patch against bcm43xx-d80211.

> @@ -1534,7 +1534,7 @@ static void handle_irq_noise(struct bcm4
>   		goto generate_new;
> 
>   	/* Get the noise samples. */
> -	assert(bcm->noisecalc.nr_samples <= 8);
> +	assert(bcm->noisecalc.nr_samples < 8);
>   	i = bcm->noisecalc.nr_samples;
>   	noise[0] = limit_value(noise[0], 0, ARRAY_SIZE(radio->nrssi_lt) - 1);
>   	noise[1] = limit_value(noise[1], 0, ARRAY_SIZE(radio->nrssi_lt) - 1);
> 
> ========================
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Greetings Michael.
