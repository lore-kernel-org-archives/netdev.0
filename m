From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Wed, 16 Dec 2009 10:13:56 +1000
Message-ID: <4B282644.8030104@snapgear.com>
References: <cover.1260785451.git.baruch@tkos.co.il> <fb518184b206ec2727deda111cc5364134ace69a.1260785451.git.baruch@tkos.co.il> <20091214103348.GV15126@pengutronix.de> <20091215083142.GB18290@jasper.tkos.co.il> <4B277878.1050804@snapgear.com> <20091215201109.GA2621@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:54594 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934279AbZLPAPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 19:15:17 -0500
In-Reply-To: <20091215201109.GA2621@tarshish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Baruch,

Baruch Siach wrote:
> Hi Greg,
> 
> On Tue, Dec 15, 2009 at 09:52:24PM +1000, Greg Ungerer wrote:
>> On 12/15/2009 06:31 PM, Baruch Siach wrote:
> 
> [snip]
> 
>>> +#ifndef CONFIG_M5272
>> I would suggest making this conditional on FEC_MIIGSK_ENR.
>> Although the CONFIG_M5272 is the only case here currently,
>> that may change over the years. And using this here may not
>> be obvious to the causual code reader, since the register
>> offset definitions don't explicitly key on CONFIG_M5272.
> 
> OK, I'll change this conditional.
> 
> Can I take this as an Ack from you?

With that conditional check changed, sure:

Acked-by:  Greg Ungerer <gerg@uclinux.org>

Regards
Greg



>>> +	if (fep->phy_interface == PHY_INTERFACE_MODE_RMII) {
>>> +		/* disable the gasket and wait */
>>> +		writel(0, fep->hwp + FEC_MIIGSK_ENR);
>>> +		while (readl(fep->hwp + FEC_MIIGSK_ENR)&  4)
>>> +			udelay(1);
>>> +
>>> +		/* configure the gasket: RMII, 50 MHz, no loopback, no echo */
>>> +		writel(1, fep->hwp + FEC_MIIGSK_CFGR);
>>> +
>>> +		/* re-enable the gasket */
>>> +		writel(2, fep->hwp + FEC_MIIGSK_ENR);
>>> +	}
>>> +#endif
> 


-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
