From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH v4] lpc32xx: Added ethernet driver: smp_wmb()
Date: Tue, 06 Mar 2012 11:43:57 +0100
Message-ID: <4F55EA6D.3070602@antcom.de>
References: <1330983641-32622-1-git-send-email-stigge@antcom.de> <1330987524.2538.61.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org,
	arnd@arndb.de, baruch@tkos.co.il, joe@perches.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330987524.2538.61.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/05/2012 11:45 PM, Ben Hutchings wrote:
>> +	/* Clear and enable interrupts */
>> +	writel(0xFFFF, LPC_ENET_INTCLEAR(pldat->net_base));
>> +	lpc_eth_enable_int(pldat->net_base);
>> +
>> +	/* Get the next TX buffer output index */
>> +	pldat->num_used_tx_buffs = 0;
>> +	pldat->last_tx_idx =
>> +		readl(LPC_ENET_TXCONSUMEINDEX(pldat->net_base));
> 
> Doesn't this need to be done *before* enabling interrupts?  Also, I
> think you need an smp_wmb() so that the interrupt handler is guaranteed
> to see all these writes.

Do you mean _one_ smp_wmb() directly after lpc_eth_enable_int() (which
I'm moving behind the above code?

Note that there is no SMP in LPCs and NXP is not planning to build one
AFAIK. However, I'm fine with including smp_wmb() anyway for completeness.

Thanks in advance,

Roland
