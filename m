From: Arend van Spriel <aspriel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: sdio: Increase the default timeouts a bit
Date: Mon, 25 Jan 2016 16:39:56 +0100
Message-ID: <56A641CC.6020500@gmail.com>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
 <CAGRGNgXWE=b52Mcy8NsKBZS_4gz-TUiuFipjsuTZh1xjja=uUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Doug Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sjoerd Simons <sjoerd.simons-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGRGNgXWE=b52Mcy8NsKBZS_4gz-TUiuFipjsuTZh1xjja=uUg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 25-01-16 12:06, Julian Calaby wrote:
> Hi Sjoerd,
> 
> On Mon, Jan 25, 2016 at 9:47 PM, Sjoerd Simons
> <sjoerd.simons-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org> wrote:
>> On a Radxa Rock2 board with a Ampak AP6335 (Broadcom 4339 core) it seems
>> the card responds very quickly most of the time, unfortunately during
>> initialisation it sometimes seems to take just a bit over 2 seconds to
>> respond.
>>
>> This results intialization failing with message like:
>>   brcmf_c_preinit_dcmds: Retreiving cur_etheraddr failed, -52
>>   brcmf_bus_start: failed: -52
>>   brcmf_sdio_firmware_callback: dongle is not responding
>>
>> Increasing the timeout to allow for a bit more headroom allows the
>> card to initialize reliably.
>>
>> A quick search online after diagnosing/fixing this showed that Google
>> has a similar patch in their ChromeOS tree, so this doesn't seem
>> specific to the board I'm using.
>>
>> Signed-off-by: Sjoerd Simons <sjoerd.simons-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
> 
> Looks sane to me.
> 
> Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Not really a cleanup patch :-p , but thanks for the review.

Regards,
Arend

> 
>>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
>> index dd66143..75ac4bd 100644
>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
>> @@ -45,8 +45,8 @@
>>  #include "chip.h"
>>  #include "firmware.h"
>>
>> -#define DCMD_RESP_TIMEOUT      msecs_to_jiffies(2000)
>> -#define CTL_DONE_TIMEOUT       msecs_to_jiffies(2000)
>> +#define DCMD_RESP_TIMEOUT      msecs_to_jiffies(2500)
>> +#define CTL_DONE_TIMEOUT       msecs_to_jiffies(2500)
>>
>>  #ifdef DEBUG
>>
>> --
>> 2.7.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
