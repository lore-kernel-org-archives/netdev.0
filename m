From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: next-20151126 build: 3 failures 15 warnings (next-20151126)
Date: Thu, 26 Nov 2015 14:39:40 +0200
Message-ID: <87y4dllysz.fsf@kamboji.qca.qualcomm.com>
References: <E1a1sVV-00079q-My@optimist> <20151126121551.GE1929@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <kernel-build-reports-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>,
	<linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>, <linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151126121551.GE1929-GFdadSzt00ze9xe1eoZjHA@public.gmane.org> (Mark Brown's message of
	"Thu, 26 Nov 2015 12:15:51 +0000")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> On Thu, Nov 26, 2015 at 09:06:25AM +0000, Build bot for Mark Brown wrote:
>
> Today's -next fails to build an arm64 allmodconfig due to:
>
>> 	arm64-allmodconfig
>> ../drivers/net/wireless/ath/ath10k/thermal.c:119:6: error: redefinition of 'ath10k_thermal_event_temperature'
>> ../drivers/net/wireless/ath/ath10k/thermal.c:136:6: error: redefinition of 'ath10k_thermal_set_throttling'
>> ../drivers/net/wireless/ath/ath10k/thermal.c:162:5: error: redefinition of 'ath10k_thermal_register'
>> ../drivers/net/wireless/ath/ath10k/thermal.c:216:6: error: redefinition of 'ath10k_thermal_unregister'
>
> This is happening because there are stub functions provided in the
> driver's thermal.h for !THERMAL cases but these are guarded by an #ifdef
> not an #if and so fails to do the right thing if the thermal code is
> built as a module.

Thanks, I'll apply the fix soon. Just wait for comments from others
first.

> It looks like this was somehow triggered as part of the reorganisation
> of the WiFi directory structure.

This is surprising and also worrying, any ideas why? It would be good to
understand the root cause in case there's a bug in wireless drivers
directory reorganisation.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
