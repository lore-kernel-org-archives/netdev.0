From: Andrei Pistirica <andrei.pistirica@microchip.com>
Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Fri, 18 Nov 2016 11:07:11 +0100
Message-ID: <27516aeb-b8f9-dc38-4d01-d2a5c5cf44dd@microchip.com>
References: <BN3PR07MB2516B2EBCF0AE7079971DBF6C9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJ-ZYjGg-3CbWD2Ka8yKzOokUxS8ZHHOJXa2Z6anuTr7Q@mail.gmail.com>
 <e6773b4e-a633-4754-893d-fd2351d07459@atmel.com>
 <BN3PR07MB2516EBCDD8822FC5F8A9095FC9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVEC+RqUMQF39oe2EuCoisX6dCwRQ3G81zFMqoOHU3HpfPHQ@mail.gmail.com>
 <BN3PR07MB25166D8301C60C4A35402AB1C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
 <a315b554-8b44-ac82-a104-e382940750bb@atmel.com>
 <BN3PR07MB251655CAFDB38CCF0F240BB5C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJT=b2jmQAtsTeXEwWad8L2VEVW1GOyTY9XYR5qUq=4Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Rafal Ozieblo <rafalo@cadence.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Harini Katakam <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFcVECJT=b2jmQAtsTeXEwWad8L2VEVW1GOyTY9XYR5qUq=4Mw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Harini,

On 18.11.2016 10:43, Harini Katakam wrote:
> Hi Rafal,
>
> On Fri, Nov 18, 2016 at 3:00 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
>>> -----Original Message-----
>>> From: Nicolas Ferre [mailto:nicolas.ferre@atmel.com]
>>> Sent: 18 listopada 2016 10:10
>>> To: Rafal Ozieblo; Harini Katakam; Andrei Pistirica
>>> Cc: harini.katakam@xilinx.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
>>> Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
>>>
>>> Le 18/11/2016 à 09:59, Rafal Ozieblo a écrit :
>>>> Hello,
>>>>
>>>>> From: Harini Katakam [mailto:harinikatakamlinux@gmail.com]
>>>>> Sent: 18 listopada 2016 05:30
>>>>> To: Rafal Ozieblo
>>>>> Cc: Nicolas Ferre; harini.katakam@xilinx.com; netdev@vger.kernel.org;
>>>>> linux-kernel@vger.kernel.org
>>>>> Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support
>>>>> for GEM
>>>>>
>>>>> Hi Rafal,
>>>>>
>>>>> On Thu, Nov 17, 2016 at 7:05 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
>>>>>> -----Original Message-----
>>>>>> From: Nicolas Ferre [mailto:nicolas.ferre@atmel.com]
>>>>>> Sent: 17 listopada 2016 14:29
>>>>>> To: Harini Katakam; Rafal Ozieblo
>>>>>> Cc: harini.katakam@xilinx.com; netdev@vger.kernel.org;
>>>>>> linux-kernel@vger.kernel.org
>>>>>> Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing
>>>>>> support for GEM
>>>>>>
>>>>>>> Le 17/11/2016 à 13:21, Harini Katakam a écrit :
>>>>>>>> Hi Rafal,
>>>>>>>>
>>>>>>>> On Thu, Nov 17, 2016 at 5:20 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
>>>>>>>>> Hello,
>>>>>>>>> I think, there could a bug in your patch.
>>>>>>>>>
>>>>>>>>>> +
>>>>>>>>>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>>>>>>>>>> +             dmacfg |= GEM_BIT(ADDR64); #endif
>>>>>>>>>
>>>>>>>>> You enable 64 bit addressing (64b dma bus width) always when appropriate architecture config option is enabled.
>>>>>>>>> But there are some legacy controllers which do not support that feature. According Cadence hardware team:
>>>>>>>>> "64 bit addressing was added in July 2013. Earlier version do not have it.
>>>>>>>>> This feature was enhanced in release August 2014 to have separate upper address values for transmit and receive."
>>>>>>>>>
>>>>>>>>>> /* Bitfields in NSR */
>>>>>>>>>> @@ -474,6 +479,10 @@
>>>>>>>>>>  struct macb_dma_desc {
>>>>>>>>>  >      u32     addr;
>>>>>>>>>>       u32     ctrl;
>>>>>>>>>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>>>>>>>>>> +     u32     addrh;
>>>>>>>>>> +     u32     resvd;
>>>>>>>>>> +#endif
>>>>>>>>>>  };
>>>>>>>>>
>>>>>>>>> It will not work for legacy hardware. Old descriptor is 2 words wide, the new one is 4 words wide.
>>>>>>>>> If you enable CONFIG_ARCH_DMA_ADDR_T_64BIT but hardware doesn't
>>>>>>>>> support it at all, you will miss every second descriptor.
>>>>>>>>>
>>>>>>>>
>>>>>>>> True, this feature is not available in all of Cadence IP versions.
>>>>>>>> In fact, the IP version Zynq does not support this. But the one in ZynqMP does.
>>>>>>>> So, we enable kernel config for 64 bit DMA addressing for this SoC
>>>>>>>> and hence the driver picks it up. My assumption was that if the
>>>>>>>> legacy IP does not support
>>>>>>>> 64 bit addressing, then this DMA option wouldn't be enabled.
>>>>>>>>
>>>>>>>> There is a design config register in Cadence IP which is being
>>>>>>>> read to check for 64 bit address support - DMA mask is set based on that.
>>>>>>>> But the addition of two descriptor words cannot be based on this runtime check.
>>>>>>>> For this reason, all the static changes were placed under this check.
>>>>>>>
>>>>>>> We have quite a bunch of options in this driver to determinate what is the real capacity of the underlying hardware.
>>>>>>> If HW configuration registers are not appropriate, and it seems they are not, I would advice to simply use the DT compatibility string.
>>>>>>>
>>>>>>> Best regards,
>>>>>>> --
>>>>>>> Nicolas Ferre
>>>>>>
>>>>>> HW configuration registers are appropriate. The issue is that this code doesn’t use the capability bit to switch between different dma descriptors (2 words vs. 4 words).
>>>>>> DMA descriptor size is chosen based on kernel configuration, not based on hardware capabilities.
>>>>>
>>>>> HW configuration register does give appropriate information.
>>>>> But addition of two address words in the macb descriptor structure is a static change.
>>>>>
>>>>> +static inline void macb_set_addr(struct macb_dma_desc *desc,
>>>>> +dma_addr_t
>>>>> +addr) {
>>>>> +       desc->addr = (u32)addr;
>>>>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>>>>> +       desc->addrh = (u32)(addr >> 32); #endif
>>>>> +
>>>>>
>>>>> Even if the #ifdef condition here is changed to HW config check, addr and addrh are different.
>>>>> And "addrh" entry has to be present for 64 bit desc case to be handled separately.
>>>>> Can you please tell me how you propose change in DMA descriptor
>>>>> structure from
>>>>> 4 to 2 or 2 to 4 words *after* reading the DCFG register?
>>>>
>>>> It is very complex problem. I wrote to you because I faced the same issue. I'm working on PTP implementation for macb. When PTP is enabled there are additional two words in buffer descriptor.
>>>
>>> Moreover, we can use PTP without the 64bits descriptor support (early GEM revisions).
>>>
>>> BTW, note that there is an initiative ongoing with Andrei to support
>>> PTP/1588 on these devices with patches already send: please synchronize with him.
>>> https://urldefense.proofpoint.com/v2/url?u=https-3A__marc.info_-3Fl-3Dlinux-2Dnetdev-26m-3D147282092309112-26w-3D3&d=DgIDaQ&c=aUq983L2pue2FqKFoP6PGHMJQyoJ7kl3s3GZ-_haXqY&r=MWSZN_jP4BHjuU9UFsrndALGeJqIXzD0WtGCtCg4L5E&m=jUmZzqwn1uRrvcqF3BHCHFC6ZsKoZkU3vT8gJ-7fnsE&s=kr_km0MKQBzpkaOt0fkM-FIajN1-pOylzzTjsXi-vak&e=
>>> or
>>> https://urldefense.proofpoint.com/v2/url?u=https-3A__patchwork.kernel.org_patch_9310989_&d=DgIDaQ&c=aUq983L2pue2FqKFoP6PGHMJQyoJ7kl3s3GZ-_haXqY&r=MWSZN_jP4BHjuU9UFsrndALGeJqIXzD0WtGCtCg4L5E&m=jUmZzqwn1uRrvcqF3BHCHFC6ZsKoZkU3vT8gJ-7fnsE&s=ZbXVD5Lb5zGn7wUKIPYHxagIEKp_vJvrnkRa4qJfmTY&e=
>>> and
>>> https://urldefense.proofpoint.com/v2/url?u=https-3A__patchwork.kernel.org_patch_9310991_&d=DgIDaQ&c=aUq983L2pue2FqKFoP6PGHMJQyoJ7kl3s3GZ-_haXqY&r=MWSZN_jP4BHjuU9UFsrndALGeJqIXzD0WtGCtCg4L5E&m=jUmZzqwn1uRrvcqF3BHCHFC6ZsKoZkU3vT8gJ-7fnsE&s=Z0kRqUqh5Is4TmuaY7A4hnpizfdeq3HrgPhyDAMLuA8&e=
>>>
>>> Regards,
>>> --
>>> Nicolas Ferre
>>
>> Above patch doesn’t use hardware timestamps in descriptors at all. It doesn't use appropriate accuracy.
>> We have our PTP patch ready, which use timestamps from descriptor. But we have not sent it yet because of compatibility issue.
>> Of course, we can do it like Harini did:
>>
>> struct macb_dma_desc {
>>         u32     addr;
>>         u32     ctrl;
>> #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>>         u32     addrh;
>>         u32     resvd;
>> #endif
>> #if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
>>         u32     dma_desc_ts_1;
>>         u32     dma_desc_ts_2;
>> #endif
>> };
>>
>> But in that approach we lose backward compatibility.
>>
>> What are your suggestion? Can we send patch like it is or wait for some common solution with backward compatibility?
>>
>
> Yes, Andre's version of Cadence does not ability to report have RX timestamp.
> The version I worked with did. This is the old series I sent:
> https://lkml.org/lkml/2015/9/11/92
> But right now, i'm working on building on top of Andre's changes.

I'm addressing maintainer's feedback on both patches:
https://patchwork.kernel.org/patch/9310989/
https://patchwork.kernel.org/patch/9310991/

I've done all suggested updates, except the numerous 64bit divisions in 
the frequency adjustment callback. I've implemented a different 
algorithm which uses 2 64bit division, but I couldn't find a way to use 
only 1.

Also, I have a version with timecounter/cyclecounter which shows a much 
better accuracy (less than 100ns level). In my opinion this could be a 
better implementation. What is you opinion about this? Did you try it?

Tuesday I can send an updated version of these patches.

>
> Regards,
> Harini
>

Regards,
Andrei
