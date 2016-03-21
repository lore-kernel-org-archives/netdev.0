From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 3/5] ath9k: fix buffer overrun for ar9287
Date: Mon, 21 Mar 2016 16:23:59 +0200
Message-ID: <87lh5bhpts.fsf@purkki.adurom.net>
References: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
	<1457965120-3155420-4-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457965120-3155420-4-git-send-email-arnd-r2nGTMty4D4@public.gmane.org> (Arnd
	Bergmann's message of "Mon, 14 Mar 2016 15:18:36 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> writes:

> Code that was added back in 2.6.38 has an obvious overflow
> when accessing a static array, and at the time it was added
> only a code comment was put in front of it as a reminder
> to have it reviewed properly.
>
> This has not happened, but gcc-6 now points to the specific
> overflow:
>
> drivers/net/wireless/ath/ath9k/eeprom.c: In function 'ath9k_hw_get_gain_boundaries_pdadcs':
> drivers/net/wireless/ath/ath9k/eeprom.c:483:44: error: array subscript is above array bounds [-Werror=array-bounds]
>      maxPwrT4[i] = data_9287[idxL].pwrPdg[i][4];
>                    ~~~~~~~~~~~~~~~~~~~~~~~~~^~~
>
> It turns out that the correct array length exists in the local
> 'intercepts' variable of this function, so we can just use that
> instead of hardcoding '4', so this patch changes all three
> instances to use that variable. The other two instances were
> already correct, but it's more consistent this way.
>
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> Fixes: 940cd2c12ebf ("ath9k_hw: merge the ar9287 version of ath9k_hw_get_gain_boundaries_pdadcs")

Dave already applies this so I can skip this.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
