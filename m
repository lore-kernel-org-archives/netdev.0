From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH v2] brcmfmac: prohibit ACPI power management for brcmfmac
 driver
Date: Thu, 7 May 2015 10:30:40 +0200
Message-ID: <554B22B0.6080708@broadcom.com>
References: <55463E19.7070709@linux.intel.com> <554AC8EB.9040403@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
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
To: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <554AC8EB.9040403@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/15 04:07, Fu, Zhonghui wrote:
>
> Hi,
>
> Any comments are welcome.

Having some time to spare while spending my vacation so here it is.

> Thanks,
> Zhonghui
>
> On 2015/5/3 23:26, Fu, Zhonghui wrote:
>> ACPI will manage WiFi chip's power state during suspend/resume
>> process on some tablet platforms(such as ASUS T100TA). This is
>> not supported by brcmfmac driver now, and the context of WiFi
>> chip will be damaged after resume. This patch informs ACPI not
>> to manage WiFi chip's power state.
>>
>> Signed-off-by: Zhonghui Fu<zhonghui.fu@linux.intel.com>
>> ---
>> Changes in v2:
>> - Another implementation.
>>
>>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    8 ++++++++
>>   1 files changed, 8 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> index 9b508bd..6c519e3 100644
>> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> @@ -33,6 +33,7 @@
>>   #include<linux/suspend.h>
>>   #include<linux/errno.h>
>>   #include<linux/module.h>
>> +#include<linux/acpi.h>
>>   #include<net/cfg80211.h>
>>
>>   #include<defs.h>
>> @@ -1114,6 +1115,8 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
>>   	int err;
>>   	struct brcmf_sdio_dev *sdiodev;
>>   	struct brcmf_bus *bus_if;
>> +	struct device *dev;
>> +	struct acpi_device *adev;
>>
>>   	brcmf_dbg(SDIO, "Enter\n");
>>   	brcmf_dbg(SDIO, "Class=%x\n", func->class);
>> @@ -1121,6 +1124,11 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
>>   	brcmf_dbg(SDIO, "sdio device ID: 0x%04x\n", func->device);
>>   	brcmf_dbg(SDIO, "Function#: %d\n", func->num);
>>
>> +	/* prohibit ACPI power management for this device */
>> +	dev =&func->dev;
>> +	if (adev = ACPI_COMPANION(dev))

While I understand what you are doing here it makes someone reading the 
code wonder whether a mistake has been made. So I would prefer to have 
the assignment separate for the if statement.

For the update patch you may add:

Acked-by: Arend van Spriel <arend@broadcom.com>

Regards,
Arend
>> +		adev->flags.power_manageable = 0;
>> +
>>   	/* Consume func num 1 but dont do anything with it. */
>>   	if (func->num == 1)
>>   		return 0;
>> -- 1.7.1
>>
>
