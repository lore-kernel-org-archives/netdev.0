From: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Subject: Re: usb/net/hso: WARNING: ungligned urb->setup_dma
Date: Fri, 3 Mar 2017 16:31:31 +0100
Message-ID: <565616b2-e8f7-e704-1ac5-f84b57ca5ba8@i2se.com>
References: <20170228082810.syn656o2zzms7urf@tarshish>
 <20170228120134.4f65yihw7x22hfwd@tarshish>
 <36230d64-4ba0-7515-1131-ecf3ab9f352c@i2se.com>
 <20170228180700.3fxpimfysnhm6uis@tarshish>
 <1515966850.16584.1488306729844@email.1und1.de>
 <20170301105437.tmm6ovmnrhce3ofa@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Youn <johnyoun-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>,
 linux-rpi-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Return-path: <linux-rpi-kernel-bounces+glkr-linux-rpi-kernel=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170301105437.tmm6ovmnrhce3ofa@tarshish>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rpi-kernel>,
 <mailto:linux-rpi-kernel-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rpi-kernel/>
List-Post: <mailto:linux-rpi-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rpi-kernel-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rpi-kernel>,
 <mailto:linux-rpi-kernel-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "linux-rpi-kernel" <linux-rpi-kernel-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rpi-kernel-bounces+glkr-linux-rpi-kernel=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Baruch,

Am 01.03.2017 um 11:54 schrieb Baruch Siach:
> Hi Stefan,
>
> On Tue, Feb 28, 2017 at 07:32:09PM +0100, Stefan Wahren wrote: 
>>> Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org> hat am 28. Februar 2017 um 19:07 geschrieben:
>>> On Tue, Feb 28, 2017 at 05:21:18PM +0100, Stefan Wahren wrote:
>>>> Am 28.02.2017 um 13:01 schrieb Baruch Siach:
>>>>> On Tue, Feb 28, 2017 at 10:28:10AM +0200, Baruch Siach wrote:
>>>>>> I'm hitting this warning consistently on my Raspberry Pi 3 running 
>>>>>> kernel
>>>>>> v4.10.1 with some unrelated device tree changes, and a debug print (below).
>>>>>> The device identifies as "GlobeTrotter HSDPA Modem", VID: 0af0, PID: 6971.
>>>>>> The warning triggers consistently on first write access to /dev/ttyHS0 that
>>>>>> ModemManager attempts. The first line in the log is my debug print.
>>>>> I tested the same hardware successfully on an i.MX6 CuBox-i (ARM32) using the
>>>>> same kernel version (4.10.1), and on an x86_64 PC (4.9). So this seems to be
>>>>> platform specific. I don't have any other ARM64 machine at the moment, though.
>>>> those platforms usually doesn't use the dwc2 USB host controller. So it
>>>> should be tested with another dwc2 platform.
>>> The code that initializes setup_dma is not under drivers/usb/dwc2/. Though the 
>>> problem looks like memory corruption, so its cause might be anywhere.
>> only a suspicion, but could you please try this patch [1]?
>>
>> [1] - https://patchwork.kernel.org/patch/9166771/
> It doesn't change anything.
>
> My guess is that source of the issue is memory corruption that just happens to 
> corrupt also the setup_dma field of struct urb. In other words, it has nothing 
> to do with DMA, IMO.

may you could use

CONFIG_DMA_API_DEBUG

or

CONFIG_SLUB_DEBUG

in order to find the source?

>
> Thanks,
> baruch
>
