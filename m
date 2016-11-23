From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Wed, 23 Nov 2016 09:24:50 +0100
Message-ID: <479c8380-82f7-f5c9-814d-dc3378feec5b@broadcom.com>
References: <201611111820.52072@pali> <20161122153141.GT13735@pali>
 <CA+BoTQkSOJ85PiT=pjmH234sviCj-LVWWM=64KbCe4AG9CMNUg@mail.gmail.com>
 <201611221805.13606@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>, Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>,
        Michal Kazior <michal.kazior@tieto.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201611221805.13606@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22-11-2016 18:05, Pali Rohár wrote:
> On Tuesday 22 November 2016 17:14:28 Michal Kazior wrote:
>> On 22 November 2016 at 16:31, Pali Rohár <pali.rohar@gmail.com> wrote:
>>> On Tuesday 22 November 2016 16:22:57 Michal Kazior wrote:
>>>> On 21 November 2016 at 16:51, Pali Rohár <pali.rohar@gmail.com>
>>>> wrote:
>>>>> On Friday 11 November 2016 18:20:50 Pali Rohár wrote:
>>>>>> Hi! I will open discussion about mac address and calibration
>>>>>> data for wl1251 wireless chip again...
>>>>>>
>>>>>> Problem: Mac address & calibration data for wl1251 chip on
>>>>>> Nokia N900 are stored on second nand partition (mtd1) in
>>>>>> special proprietary format which is used only for Nokia N900
>>>>>> (probably on N8x0 and N9 too). Wireless driver wl1251.ko
>>>>>> cannot work without mac address and calibration data.
>>>>
>>>> Same problem applies to some ath9k/ath10k supported routers. Some
>>>> even carry mac address as implicit offset from ethernet mac
>>>> address. As far as I understand OpenWRT cooks cal blobs on first
>>>> boot prior to loading modules.
>>>
>>> So... wl1251 on Nokia N900 is not alone and this problem is there
>>> for more drivers and devices. Which means we should come up with
>>> some generic solution.
>>
>> This isn't particularly a problem for ath9k/ath10k.
>>
>> Let me give you more background on ath10k.
>>
>> ath10k devices can come with caldata and macaddr stored in their
>> OTP/EEPROM. In that case a generic "template" board file is used.
>> Userspace doesn't need to do anything special.
>>
>> Some vendors however decide to use flash partition to store caldata.
>> In that case ath10k expects userspace to prepare
>> cal-$bus-$devname.bin files, each for a different radio (you can
>> have multiple radios on a system).
>>
>> Now translating this for wl1251 I would expect it should also use
>> something like wl1251-nvs-sdio-0x0001.bin for devices like N900 that
>> have caldata on flash partition (instead of the generic
>> wl1251-nvs.bin). I'm not sure if wl1251-nvs.bin is something
>> comparable to (the generic) board.bin ath10k has though. Maybe the
>> entire idea behind wl1251-nvs.bin is flawed as it's supposed to be
>> device specific and is oblivious to possibility of having multiple
>> wl1251 radios on one system (probably sane assumption from practical
>> standpoint but still).
> 
> Basically nvs data are device specific, in ideal case they should be 
> generated in factory by some calibration process (or so).

For brcmfmac we have what we call nvram data, which is determined during
manufacturing. We use the firmware_class API to obtain that file, but on
router it may be stored in flash. So an API was created for that router
architecture and brcmfmac calls that API [1]. Not a generic solution but
it gets the job done. Personally, I would have liked this to be handled
behind the firmware_class API to hide the storage details from the driver.

Regards,
Arend

[1]
http://lxr.free-electrons.com/source/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c#L449
