From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/2] drivers: net: xgene: fix: Derive prefetch number
 from irq
Date: Mon, 7 Mar 2016 19:07:06 +0000
Message-ID: <20160307190705.GA27101@svinekod>
References: <1457502577-2606-1-git-send-email-isubramanian@apm.com>
 <1457502577-2606-2-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, toanle@apm.com,
	patches@apm.com, linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38683 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751748AbcCIIUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 03:20:16 -0500
Content-Disposition: inline
In-Reply-To: <1457502577-2606-2-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2016 at 09:49:36PM -0800, Iyappan Subramanian wrote:
> Prefetch buffer numbers are mapped to hardware irqs. Currently
> they are statically assigned to match with firmware irqs.
> 
> If the irq on firmware changes, prefetch buffer number on the driver
> also needs to be updated to match with the firmware.
> 
> This patch removes this static association between firmware and the
> driver by deriving the prefetch buffer number from the Linux irq.

This driver should neither care about the Linux IRQ number nor the interrupt
controller's physical IRQ number. Neither of the two are properties of the
device.

What you actually care about is the index of the interrupt pin _out_ of the
device, not _into_ the interrupt controller. As with other drivers, that should
described explicitly in the device binding. Either the interrupts should be
listed in a fixed order, or they should be given names.

> +static u8 xgene_start_cpu_bufnum(struct xgene_enet_pdata *pdata)
> +{
> +	struct irq_desc *desc;
> +	int hwirq;
> +
> +	desc = irq_to_desc(pdata->irqs[0]);
> +	hwirq = desc->irq_data.hwirq;
> +
> +	return hwirq - XGENE2_RM0_START_IRQ;
> +}

No device driver should be doing this.

Mark.
