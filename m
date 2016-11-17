From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Thu, 17 Nov 2016 14:28:49 +0100
Message-ID: <e6773b4e-a633-4754-893d-fd2351d07459@atmel.com>
References: <BN3PR07MB2516B2EBCF0AE7079971DBF6C9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJ-ZYjGg-3CbWD2Ka8yKzOokUxS8ZHHOJXa2Z6anuTr7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Harini Katakam <harinikatakamlinux@gmail.com>,
        Rafal Ozieblo <rafalo@cadence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:49719 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934570AbcKQO1w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 09:27:52 -0500
In-Reply-To: <CAFcVECJ-ZYjGg-3CbWD2Ka8yKzOokUxS8ZHHOJXa2Z6anuTr7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/11/2016 à 13:21, Harini Katakam a écrit :
> Hi Rafal,
> 
> On Thu, Nov 17, 2016 at 5:20 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
>> Hello,
>> I think, there could a bug in your patch.
>>
>>> +
>>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>>> +             dmacfg |= GEM_BIT(ADDR64);
>>> +#endif
>>
>> You enable 64 bit addressing (64b dma bus width) always when appropriate architecture config option is enabled.
>> But there are some legacy controllers which do not support that feature. According Cadence hardware team:
>> "64 bit addressing was added in July 2013. Earlier version do not have it.
>> This feature was enhanced in release August 2014 to have separate upper address values for transmit and receive."
>>
>>> /* Bitfields in NSR */
>>> @@ -474,6 +479,10 @@
>>>  struct macb_dma_desc {
>>  >      u32     addr;
>>>       u32     ctrl;
>>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>>> +     u32     addrh;
>>> +     u32     resvd;
>>> +#endif
>>>  };
>>
>> It will not work for legacy hardware. Old descriptor is 2 words wide, the new one is 4 words wide.
>> If you enable CONFIG_ARCH_DMA_ADDR_T_64BIT but hardware doesn't support it at all,
>> you will miss every second descriptor.
>>
> 
> True, this feature is not available in all of Cadence IP versions.
> In fact, the IP version Zynq does not support this. But the one in ZynqMP does.
> So, we enable kernel config for 64 bit DMA addressing for this SoC and hence
> the driver picks it up. My assumption was that if the legacy IP does not support
> 64 bit addressing, then this DMA option wouldn't be enabled.
> 
> There is a design config register in Cadence IP which is being read to
> check for 64 bit address support - DMA mask is set based on that.
> But the addition of two descriptor words cannot be based on this runtime check.
> For this reason, all the static changes were placed under this check.

We have quite a bunch of options in this driver to determinate what is
the real capacity of the underlying hardware.
If HW configuration registers are not appropriate, and it seems they are
not, I would advice to simply use the DT compatibility string.

Best regards,
-- 
Nicolas Ferre
