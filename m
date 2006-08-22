From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 4/5] d80211/bcm43xx: fix build for ARM
Date: Tue, 22 Aug 2006 20:58:37 +0200
Message-ID: <200608222058.37545.mb@bu3sch.de>
References: <20060822173241.313859000@devicescape.com> <20060822173403.GE12500@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:14555
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750879AbWHVS7f
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 14:59:35 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060822173403.GE12500@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 August 2006 19:34, David Kimdon wrote:
> ARM targets support udelay(N) where N <= 2000.
> Use mdelay() when N >= 2000.
> 
> Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
> 
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
> @@ -291,7 +291,7 @@ int bcm43xx_pctl_set_crystal(struct bcm4
>  		err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCTL_OUT, out);
>  		if (err)
>  			goto err_pci;
> -		udelay(5000);
> +		mdelay(5);

I am going to convert this to msleep anyway. (Patch is almost done)
So please drop this hunk.

>  	} else {
>  		if (bcm->current_core->rev < 5)
>  			return 0;
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
> @@ -1687,7 +1687,7 @@ int bcm43xx_radio_selectchannel(struct b
>  	radio->channel = channel;
>  	//XXX: Using the longer of 2 timeouts (8000 vs 2000 usecs). Specs states
>  	//     that 2000 usecs might suffice.
> -	udelay(8000);
> +	mdelay(8);
>  
>  	return 0;
>  }

Well, yeah. Please resubmit this patch with only this hunk.
I don't like that long delay here. I am searching for a good
solution, but I think we should live with it for now.

-- 
Greetings Michael.
