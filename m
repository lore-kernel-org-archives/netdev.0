From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH v3 6/6] ARM: davinci: da850: configure system
 configuration chip(CFGCHIP3) for emac
Date: Thu, 8 Aug 2013 16:02:30 +0530
Message-ID: <CA+V-a8smEd_75Ab-_vxjBATr8Q9Sefs0tpxc+kgQJRtuLJad=w@mail.gmail.com>
References: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
 <1371999607-6483-7-git-send-email-prabhakar.csengg@gmail.com> <51F8A4FF.8020803@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	devicetree-discuss@lists.ozlabs.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Heiko Schocher <hs@denx.de>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51F8A4FF.8020803@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sekhar,

Sorry for the  delayed response I was on leave and now back again up
and running.

On Wed, Jul 31, 2013 at 11:17 AM, Sekhar Nori <nsekhar@ti.com> wrote:
> On Sunday 23 June 2013 08:30 PM, Prabhakar Lad wrote:
>> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>>
>> This patch makes a common function for to configure emac and calls
>> it appropriately in DT and non DT boot mode. The system configuration
>> chip CFGCHIP3, controls the emac module. This patch appropriately
>> configures this register for emac and sets DA850_MII_MDIO_CLKEN_PIN
>> GPIO pin appropriately.
>>
[Snip]

>> +     if (rmii_enabled)
>> +             val |= BIT(8);
>> +     else
>> +             val &= ~BIT(8);
>> +
>> +     /* configure the CFGCHIP3 register for RMII or MII */
>> +     writel(val, cfg_chip3_base);
>> +
>> +     ret = davinci_cfg_reg(DA850_GPIO2_6);
>> +     if (ret)
>> +             pr_warn("%s:GPIO(2,6) mux setup failed\n", __func__);
>> +
>> +     ret = gpio_request(DA850_MII_MDIO_CLKEN_PIN, "mdio_clk_en");
>> +     if (ret) {
>> +             pr_warn("Cannot open GPIO %d\n", DA850_MII_MDIO_CLKEN_PIN);
>> +             return;
>> +     }
>
> You cannot do this in SoC specific code. All boards wont use a GPIO to
> choose between MII/RMII. You need to do this in a EVM specific manner.
> This just means you retain the GPIO part of code in board-da850-evm.c

OK

> and for the DT case use a board specific GPIO node. See a similar
> example in arch/arm/boot/dts/ste-nomadik-s8815.dts and how the code uses
Alrite something similar to usb-s8815 node.

> it in arch/arm/mach-nomadik/cpu-8815.c.
>
But I don't see any code to access this node in this file, can
you point me to right direction ?

Regards,
--Prabhakar Lad
