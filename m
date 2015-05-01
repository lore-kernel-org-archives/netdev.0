From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: Re: [PATCH 2/2] brcmfmac: keep WiFi chip's power during system suspension
Date: Fri, 01 May 2015 14:26:32 +0800
Message-ID: <55431C98.9030203@linux.intel.com>
References: <553DC3E3.5050802@linux.intel.com> <553DF923.5070300@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "brudley@broadcom.com" <brudley@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	"meuleman@broadcom.com" <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"pieterpg@broadcom.com" <pieterpg@broadcom.com>,
	"hdegoede@redhat.com" <hdegoede@redhat.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"brcm80211-dev-list@broadcom.com" <brcm80211-dev-list@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <553DF923.5070300@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/4/27 16:53, Arend van Spriel wrote:
> On 04/27/15 07:06, Fu, Zhonghui wrote:
>> Need to keep the power supply for WiFi chip during system suspension.
>> Otherwise, the context of WiFi chip will be lost.
>
> I already submitted a patch doing exactly the same thing [1]

OK, please ignore this patch.

What's the target kernel version of your patch?

Thanks,
Zhonghui
>
> Regards,
> Arend
>
> [1] https://patchwork.kernel.org/patch/6217391/
>
>> Signed-off-by: Zhonghui Fu<zhonghui.fu@linux.intel.com>
>> ---
>>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |   10 ++++++----
>>   1 files changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> index fdf8feb..03d3671 100644
>> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> @@ -1251,15 +1251,17 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
>>       brcmf_sdiod_freezer_on(sdiodev);
>>       brcmf_sdio_wd_timer(sdiodev->bus, 0);
>>
>> +    sdio_flags = MMC_PM_KEEP_POWER;
>>       if (sdiodev->wowl_enabled) {
>> -        sdio_flags = MMC_PM_KEEP_POWER;
>>           if (sdiodev->pdata->oob_irq_supported)
>>               enable_irq_wake(sdiodev->pdata->oob_irq_nr);
>>           else
>> -            sdio_flags = MMC_PM_WAKE_SDIO_IRQ;
>> -        if (sdio_set_host_pm_flags(sdiodev->func[1], sdio_flags))
>> -            brcmf_err("Failed to set pm_flags %x\n", sdio_flags);
>> +            sdio_flags |= MMC_PM_WAKE_SDIO_IRQ;
>>       }
>> +
>> +    if (sdio_set_host_pm_flags(sdiodev->func[1], sdio_flags))
>> +        brcmf_err("Failed to set pm_flags %x\n", sdio_flags);
>> +
>>       return 0;
>>   }
>>
>> -- 1.7.1
>>
>
