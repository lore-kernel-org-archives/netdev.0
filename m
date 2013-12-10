From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2 06/16] wl1251: configure hardware en-/decryption for
 monitor mode
Date: Tue, 10 Dec 2013 10:35:18 +0100
Message-ID: <20131210093518.GF22756@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-7-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386494714-21070-7-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!


> --- a/drivers/net/wireless/ti/wl1251/tx.c
> +++ b/drivers/net/wireless/ti/wl1251/tx.c
> @@ -287,6 +287,9 @@ static int wl1251_tx_frame(struct wl1251 *wl, struct sk_buff *skb)
>  	info = IEEE80211_SKB_CB(skb);
>  
>  	if (info->control.hw_key) {
> +		if (unlikely(wl->monitor_present))
> +			return -1;
> +


This function seems to use 0/-errno convention. So probably "return
-EINVAL"?

With that fixed:

Reviewed-by: Pavel Machek <pavel@ucw.cz>

Thanks,
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
