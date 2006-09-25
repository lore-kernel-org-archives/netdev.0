From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH,RFT] ieee80211: Move IV/ICV stripping into ieee80211_rx
Date: Mon, 25 Sep 2006 16:50:13 +0200
Message-ID: <200609251650.13912.mb@bu3sch.de>
References: <20060924224317.D294E7B40A0@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, netdev@vger.kernel.org, jketreno@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:2495
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750704AbWIYOuS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 10:50:18 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060924224317.D294E7B40A0@zog.reactivated.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 25 September 2006 00:43, Daniel Drake wrote:
> This patch adds a host_strip_iv_icv flag to ieee80211 which indicates that
> ieee80211_rx should strip the IV/ICV/other security features from the payload.
> This saves on some memmove() calls in the driver and seems like something that
> belongs in the stack as it can be used by bcm43xx, ipw2200, and zd1211rw
> 
> I need someone to test this on ipw2200 as I don't have the hardware.
> As hardware decryption is disabled in bcm43xx I'm guessing that the code doesn't
> work yet? Either way I have added in the necessary changes should it be
> enabled in the future.
> 
> This patch also adds some sensible variable reuse (idx vs keyidx) in
> ieee80211_rx
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> 

> Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -4034,6 +4034,9 @@ static int bcm43xx_init_private(struct b
>  	bcm->ieee->host_build_iv = 0;
>  	bcm->ieee->host_encrypt = 1;
>  	bcm->ieee->host_decrypt = 1;
> +
> +	/* required when hardware decryption is enabled */
> +	/* bcm->ieee->host_strip_iv_icv = 1; */

Well, that line get's a NACK.
Go and correctly set that flag from bcm43xx_wx.c
The rest of the patch seems to be ok.

-- 
Greetings Michael.
