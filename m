From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Readd dropped assignment
Date: Wed, 18 Oct 2006 16:40:00 +0200
Message-ID: <200610181640.01140.mb@bu3sch.de>
References: <20061017231212.A73D77B40A0@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Larry.Finger@lwfinger.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:31640
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161049AbWJROkl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 10:40:41 -0400
To: linville@tuxdriver.com
In-Reply-To: <20061017231212.A73D77B40A0@zog.reactivated.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 18 October 2006 01:12, Daniel Drake wrote:
> Larry Finger pointed out a problem with my ieee80211 IV/ICV stripping patch,
> which I forgot about. Sorry about that.
> 
> The patch readds the frame_ctl assignment which was accidently dropped.
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>

Whoops. Please merge this as fast as possible, John.
That's a real bug which prevents RX from working.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

> Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> @@ -543,6 +543,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
>  		break;
>  	}
>  
> +	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
>  	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
>  	case IEEE80211_FTYPE_MGMT:
>  		ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
> 

-- 
Greetings Michael.
