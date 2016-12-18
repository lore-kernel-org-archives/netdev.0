From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Sun, 18 Dec 2016 21:08:43 +0100
Message-ID: <fd180271-1cd4-9891-e3d5-ae9cd0fb088b@broadcom.com>
References: <201611111820.52072@pali> <201612181204.52928@pali>
 <83b2e9a4-f990-68a8-241e-375e46448d47@broadcom.com> <201612181309.01298@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Daniel Wagner <wagi@monom.org>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Tom Gundersen <teg@jklm.no>,
        Johannes Berg <johannes@sipsolutions.net>,
        Ming Lei <ming.lei@canonical.com>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        David Woodhouse
To: =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201612181309.01298@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18-12-2016 13:09, Pali Rohár wrote:
> On Sunday 18 December 2016 12:54:00 Arend Van Spriel wrote:
>> On 18-12-2016 12:04, Pali Rohár wrote:
>>> On Sunday 18 December 2016 11:49:53 Arend Van Spriel wrote:
>>>> On 16-12-2016 11:40, Pali Rohár wrote:
>>>>> On Friday 16 December 2016 08:25:44 Daniel Wagner wrote:
>>>>>> On 12/16/2016 03:03 AM, Luis R. Rodriguez wrote:
>>>>>>> For the new API a solution for "fallback mechanisms" should be
>>>>>>> clean though and I am looking to stay as far as possible from
>>>>>>> the existing mess. A solution to help both the old API and new
>>>>>>> API is possible for the "fallback mechanism" though -- but for
>>>>>>> that I can only refer you at this point to some of Daniel
>>>>>>> Wagner and Tom Gunderson's firmwared deamon prospect. It
>>>>>>> should help pave the way for a clean solution and help address
>>>>>>> other stupid issues.
>>>>>>
>>>>>> The firmwared project is hosted here
>>>>>>
>>>>>> https://github.com/teg/firmwared
>>>>>>
>>>>>> As Luis pointed out, firmwared relies on
>>>>>> FW_LOADER_USER_HELPER_FALLBACK, which is not enabled by default.
>>>>>
>>>>> I know. But it does not mean that I cannot enable this option at
>>>>> kernel compile time.
>>>>>
>>>>> Bigger problem is that currently request_firmware() first try to
>>>>> load firmware directly from VFS and after that (if fails)
>>>>> fallback to user helper.
>>>>>
>>>>> So I would need to extend kernel firmware code with new function
>>>>> (or flag) to not use VFS and try only user mode helper.
>>>>
>>>> Why do you need the user-mode helper anyway. This is all static
>>>> data, right?
>>>
>>> Those are static data, but device specific!
>>
>> So what?
>>
>>>> So why not cook up a firmware file in user-space once and put
>>>> it in /lib/firmware for the driver to request directly.
>>>
>>> 1. Violates FHS
>>
>> How?
>>
>>> 2. Does not work for readonly /, readonly /lib, readonly
>>> /lib/firmware
>>
>> Que?
>>
>>> 3. Backup & restore of rootfs between same devices does not work
>>> (as rootfs now contains device specific data).
>>
>> True.
>>
>>> 4. Sharing one rootfs (either via nfs or other technology) does not
>>> work for more devices (even in state when rootfs is used only by
>>> one device at one time).
>>
>> Indeed.
>>
>>> And it is common that N900 developers have rootfs in laptop and via
>>> usb (cdc_ether) exports it over nfs to N900 device and boot
>>> system. It basically break booting from one nfs-exported rootfs,
>>> as that export become model specific...
>>
>> These are all you choices and more a logistic issue. If your take is
>> that udev is the way to solve those, fine by me.
>>
>>>> Seems a bit
>>>> overkill to have a {e,}udev or whatever daemon running if the
>>>> result is always the same. Just my 2 cents.
>>>
>>> No it is not. It will break couple of other things in Linux and
>>> device
>>
>> Now I am curious. What "couple of other things" will be broken.
>>
>>> and model specific calibration data should not be in /lib/firmware!
>>> That directory is used for firmware files, not calibration.
>>
>> What is "firmware"? Really. These are binary blobs required to make
>> the device work. And guess what, your device needs calibration data.
>> Why make the distinction.
>>
>> Regards,
>> Arend
> 
> File wl1251-nvs.bin is provided by linux-firmware package and contains 
> default data which should be overriden by model specific calibrated 
> data.

Ah. Someone thought it was a good idea to provide the "one ring to rule
them all". Nice.

> But overwriting that one file is not possible as it next update of 
> linux-firmware package will overwrite it back. It break any normal usage 
> of package management.
> 
> Also it is ridiculously broken by design if some "boot" files needs to 
> be overwritten to initialize hardware properly. To not break booting you 
> need to overwrite that file before first boot. But without booting 
> device you cannot read calibration data. So some hack with autoreboot 
> after boot is needed. And how to detect that we have real overwritten 
> calibration data and not default one from linux-firmware? Any heuristic 
> or checks will be broken here. And no, nothing like you need to reboot 
> your device now (and similar concept) from windows world is not 
> accepted.

Well. After reading and creating calibration data you could just rebind
the driver to the device to have it probed again. But yeah, the default
one from linux-firmware should never have been there in the first place.

> "firmware" is one for chip. Any N900 device with wl1251 chip needs 
> exactly same firmware "wl1251-fw.bin". But every N900 needs different 
> calibration data which is not firmware.

Ok. This is exactly why Luis is giving the new API different name just
calling it "data".

Regards,
Arend
