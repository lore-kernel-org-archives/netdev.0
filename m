From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Fix scaling error for 'iwlist freq' information
Date: Wed, 24 Jan 2007 00:04:01 +0100
Message-ID: <200701240004.01943.mb@bu3sch.de>
References: <45b68f8e.m8+Bl9ZfRL/zvhGv%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:35468
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965580AbXAWXFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 18:05:31 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <45b68f8e.m8+Bl9ZfRL/zvhGv%Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 January 2007 23:43, Larry Finger wrote:
> The bcm43xx driver returns the available frequencies to 'iwlist freq' with the wrong scaling.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
> 
> John,
> 
> This is to be applied to wireless-2.6. It could also be sent upstream to 2.6.20,
> but it is not very important.

ACKed. The previous rates-fix patch is also ACKed.

> Larry
> ---
> 
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> @@ -286,7 +286,7 @@ static int bcm43xx_wx_get_rangeparams(st
>  		if (j == IW_MAX_FREQUENCIES)
>  			break;
>  		range->freq[j].i = j + 1;
> -		range->freq[j].m = geo->a[i].freq;//FIXME?
> +		range->freq[j].m = geo->a[i].freq * 100000;
>  		range->freq[j].e = 1;
>  		j++;
>  	}
> @@ -294,7 +294,7 @@ static int bcm43xx_wx_get_rangeparams(st
>  		if (j == IW_MAX_FREQUENCIES)
>  			break;
>  		range->freq[j].i = j + 1;
> -		range->freq[j].m = geo->bg[i].freq;//FIXME?
> +		range->freq[j].m = geo->bg[i].freq * 100000;
>  		range->freq[j].e = 1;
>  		j++;
>  	}
> 
> ---
> 
> 
> 

-- 
Greetings Michael.
