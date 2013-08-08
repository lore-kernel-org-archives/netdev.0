From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v3 6/6] ARM: davinci: da850: configure system configuration
	chip(CFGCHIP3) for emac
Date: Thu, 8 Aug 2013 21:35:37 +0530
Message-ID: <5203C1D1.8020707@ti.com>
References: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
	<1371999607-6483-7-git-send-email-prabhakar.csengg@gmail.com>
	<51F8A4FF.8020803@ti.com>
	<CA+V-a8smEd_75Ab-_vxjBATr8Q9Sefs0tpxc+kgQJRtuLJad=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: DLOS <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
        LKML
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>,
        LAK
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Prabhakar Lad <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <CA+V-a8smEd_75Ab-_vxjBATr8Q9Sefs0tpxc+kgQJRtuLJad=w@mail.gmail.com>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 08 August 2013 04:02 PM, Prabhakar Lad wrote:
> Hi Sekhar,
> 
> Sorry for the  delayed response I was on leave and now back again up
> and running.
> 
> On Wed, Jul 31, 2013 at 11:17 AM, Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org> wrote:
>> On Sunday 23 June 2013 08:30 PM, Prabhakar Lad wrote:
>>> From: "Lad, Prabhakar" <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>
>>> This patch makes a common function for to configure emac and calls
>>> it appropriately in DT and non DT boot mode. The system configuration
>>> chip CFGCHIP3, controls the emac module. This patch appropriately
>>> configures this register for emac and sets DA850_MII_MDIO_CLKEN_PIN
>>> GPIO pin appropriately.
>>>
> [Snip]
> 
>>> +     if (rmii_enabled)
>>> +             val |= BIT(8);
>>> +     else
>>> +             val &= ~BIT(8);
>>> +
>>> +     /* configure the CFGCHIP3 register for RMII or MII */
>>> +     writel(val, cfg_chip3_base);
>>> +
>>> +     ret = davinci_cfg_reg(DA850_GPIO2_6);
>>> +     if (ret)
>>> +             pr_warn("%s:GPIO(2,6) mux setup failed\n", __func__);
>>> +
>>> +     ret = gpio_request(DA850_MII_MDIO_CLKEN_PIN, "mdio_clk_en");
>>> +     if (ret) {
>>> +             pr_warn("Cannot open GPIO %d\n", DA850_MII_MDIO_CLKEN_PIN);
>>> +             return;
>>> +     }
>>
>> You cannot do this in SoC specific code. All boards wont use a GPIO to
>> choose between MII/RMII. You need to do this in a EVM specific manner.
>> This just means you retain the GPIO part of code in board-da850-evm.c
> 
> OK
> 
>> and for the DT case use a board specific GPIO node. See a similar
>> example in arch/arm/boot/dts/ste-nomadik-s8815.dts and how the code uses
> Alrite something similar to usb-s8815 node.
> 
>> it in arch/arm/mach-nomadik/cpu-8815.c.
>>
> But I don't see any code to access this node in this file, can
> you point me to right direction ?

Look at cpu8815_eth_init() function in this file.

Thanks,
Sekhar
