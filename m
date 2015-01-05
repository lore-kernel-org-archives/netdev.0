From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: Re: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Mon, 05 Jan 2015 10:37:07 +0800
Message-ID: <54A9F8D3.1010807@linux.intel.com>
References: <54A3B1B4.7090705@linux.intel.com> <54A3DC80.1080505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	brudley@broadcom.com, Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	kvalo@codeaurora.org, linville@tuxdriver.com,
	pieterpg@broadcom.com, hdegoede@redhat.com, wens@csie.org,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54A3DC80.1080505@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Sergei,

You are right, I will apply your advice in next version of this patch.


Thanks,
Zhonghui

On 2014/12/31 19:22, Sergei Shtylyov wrote:
> Hello.
>
> On 12/31/2014 11:20 AM, Fu, Zhonghui wrote:
>
>>  From e34419970a07bfcd365f9c66bdfa552188a0cd26 Mon Sep 17 00:00:00 2001
>> From: Zhonghui Fu <zhonghui.fu@linux.intel.com>
>> Date: Mon, 29 Dec 2014 21:25:31 +0800
>> Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
>
>> WiFi chip has 2 SDIO functions, and PM core will trigger
>> twice suspend/resume operations for one WiFi chip to do
>> the same things. This patch avoid this case.
>
>> Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>
>> ---
>>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |   19 +++++++++++++++++--
>>   1 files changed, 17 insertions(+), 2 deletions(-)
>
>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> index 3c06e93..eee7818 100644
>> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> @@ -1139,11 +1139,18 @@ void brcmf_sdio_wowl_config(struct device *dev, bool enabled)
>>   static int brcmf_ops_sdio_suspend(struct device *dev)
>>   {
>>       struct brcmf_bus *bus_if = dev_get_drvdata(dev);
>> -    struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
>> +    struct brcmf_sdio_dev *sdiodev;
>>       mmc_pm_flag_t sdio_flags;
>> +    struct sdio_func *func = dev_to_sdio_func(dev);
>>
>>       brcmf_dbg(SDIO, "Enter\n");
>>
>> +    if (func->num == 2) {
>> +        return 0;
>> +    }
>
>    {} not needed.
>
> [...]
>> @@ -1164,9 +1171,17 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
>>   static int brcmf_ops_sdio_resume(struct device *dev)
>>   {
>>       struct brcmf_bus *bus_if = dev_get_drvdata(dev);
>> -    struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
>> +    struct brcmf_sdio_dev *sdiodev;
>> +    struct sdio_func *func = dev_to_sdio_func(dev);
>>
>>       brcmf_dbg(SDIO, "Enter\n");
>> +
>> +    if (func->num == 2) {
>> +        return 0;
>> +    }
>
>    Same here.
>
> [...]
>
> WBR, Sergei
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
