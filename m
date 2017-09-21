From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [v2,1/3] can: m_can: Make hclk optional
Date: Thu, 21 Sep 2017 19:38:22 +0530
Message-ID: <895ab55a-fede-3a67-27aa-1ac1af9843d7@ti.com>
References: <20170724225142.19975-2-fcooper@ti.com>
 <6f574628-51cd-0db8-e5aa-e7ae4a9cf79a@ti.com>
 <eb45fe94-c476-3919-603d-ff2a6b13487c@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Kristo, Tero" <t-kristo@ti.com>, Tony Lindgren <tony@atomide.com>,
        Linux OMAP List <linux-omap@vger.kernel.org>
To: Franklin S Cooper Jr <fcooper@ti.com>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <eb45fe94-c476-3919-603d-ff2a6b13487c@ti.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 September 2017 06:01 AM, Franklin S Cooper Jr wrote:
> 
> 
> On 08/24/2017 03:00 AM, Sekhar Nori wrote:
>> + some OMAP folks and Linux OMAP list
>>
>> On Tuesday 25 July 2017 04:21 AM, Franklin Cooper wrote:
>>> Hclk is the MCAN's interface clock. However, for OMAP based devices such as
>>> DRA7 SoC family the interface clock is handled by hwmod. Therefore, this
>>> interface clock is managed by hwmod driver via pm_runtime_get and
>>> pm_runtime_put calls. Therefore, this interface clock isn't defined in DT
>>> and thus the driver shouldn't fail if this clock isn't found.
>>
>> I agree that hclk is defined as interface clock for M_CAN IP on DRA76x.
>>
>> However, there may be a need for the driver to know the value of hclk to
>> properly configure the RAM watchdog register which has a counter
>> counting down using hclk. Looks like the driver does not use the RAM
>> watchdog today. But if there is a need to configure it in future, it
>> might be a problem.
> 
> Honestly the RAM watchdog seems like a fundamental design problem.
> This RAM watchdog seems to be used in case a request to access the
> message ram is made but it hangs for what ever reason. Its even more
> complicated since the Message RAM is external to the MCAN IP so its
> implementation or how its handled probably differs from device to
> device. From example say you do have this error it isn't clear how you
> would recover from it. A logically answer would be to reset the entire
> IP but that also assumes that Message RAM will be reset along with the
> ip which likely depends on each SoC.
> 
> But if a readl/writel command hangs will the kernel eventually throw an
> error on its on or will the driver just hang? If it does hang can a
> driver in the ISR do something to properly terminate the driver or even
> recover from it?
>>
>> Is there a restriction in OMAP architecture against passing the
>> interface clock also in the 'clocks' property in DT. I have not tried it
>> myself, but wonder if you hit an issue that led to this patch.
> 
> No but not passing the interface clock is typical.

Okay, then it sounds like it will just be easier to pass the hclk too?

So it can be used if needed in future and also so that the driver can
stay the same as today.

Thanks,
Sekhar
