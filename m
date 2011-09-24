From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 1/7] bna: Brocade 1860 IOC PLL, Reg Defs and ASIC
 Mode Changes
Date: Fri, 23 Sep 2011 19:30:26 -0700
Message-ID: <1316831427.28330.17.camel@Joe-Laptop>
References: <1316830458-24773-1-git-send-email-rmody@brocade.com>
	 <1316830458-24773-2-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44841 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752043Ab1IXCa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 22:30:27 -0400
In-Reply-To: <1316830458-24773-2-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-23 at 19:14 -0700, Rasesh Mody wrote:
> Add logic to set ASIC specfic interface in IOC, HW interface initialization
> APIs, mode based initialization and MSI-X resource allocation for 1860 with
> no asic block. Add new h/w specific register definitions and setup registers
> used by IOC logic.

trivia...

> +static struct { u32 hfn_mbox, lpu_mbox, hfn_pgn, hfn, lpu, lpu_read; }

I think it'd be better to use normal kernel declaration style,
c99 initializers and perhaps const too.

static const struct {
	u32	hfn_mbox;
	u32	lpu_mbox;
	u32	hfn_pgn;
	u32	hfn;
	u32	lpu;
	u32	lpu_read;
} ct2_reg[] = {
	etc...
	
[]
> +	if (port == 0) {
> +		ioc->ioc_regs.heartbeat = rb + CT2_BFA_IOC0_HBEAT_REG;
> +		ioc->ioc_regs.ioc_fwstate = rb + CT2_BFA_IOC0_STATE_REG;
> +		ioc->ioc_regs.alt_ioc_fwstate = rb + CT2_BFA_IOC1_STATE_REG;
> +		ioc->ioc_regs.ll_halt = rb + FW_INIT_HALT_P0;
> +		ioc->ioc_regs.alt_ll_halt = rb + FW_INIT_HALT_P1;
> +	} else {
> +		ioc->ioc_regs.heartbeat = (rb + CT2_BFA_IOC1_HBEAT_REG);
> +		ioc->ioc_regs.ioc_fwstate = (rb + CT2_BFA_IOC1_STATE_REG);
> +		ioc->ioc_regs.alt_ioc_fwstate = rb + CT2_BFA_IOC0_STATE_REG;
> +		ioc->ioc_regs.ll_halt = rb + FW_INIT_HALT_P1;
> +		ioc->ioc_regs.alt_ll_halt = rb + FW_INIT_HALT_P0;
> +	}

Inconsistent use of parentheses, I think it's better to remove them.

> +
> +	/*
> +	 * PSS control registers
> +	 */
> +	ioc->ioc_regs.pss_ctl_reg = (rb + PSS_CTL_REG);
> +	ioc->ioc_regs.pss_err_status_reg = (rb + PSS_ERR_STATUS_REG);
> +	ioc->ioc_regs.app_pll_fast_ctl_reg = (rb + CT2_APP_PLL_LCLK_CTL_REG);
> +	ioc->ioc_regs.app_pll_slow_ctl_reg = (rb + CT2_APP_PLL_SCLK_CTL_REG);

here too.

> +
> +	/*
> +	 * IOC semaphore registers and serialization
> +	 */
> +	ioc->ioc_regs.ioc_sem_reg = (rb + CT2_HOST_SEM0_REG);

etc.
