From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 5/5] sky2: Avoid down and up during sky2_reset
Date: Wed, 10 Feb 2010 09:34:08 -0800
Message-ID: <20100210093408.38a7f817@nehalam>
References: <4B72BEC9.4000004@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37389 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755028Ab0BJReO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 12:34:14 -0500
In-Reply-To: <4B72BEC9.4000004@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Feb 2010 23:12:25 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> +	if (!interrupts_disabled) {
> +		/* Disable port IRQ */
> +		u32 imask = sky2_read32(hw, B0_IMSK);
> +		imask &= ~portirq_msk[port];
> +		sky2_write32(hw, B0_IMSK, imask);
> +		sky2_read32(hw, B0_IMSK);
>  

I don't like conditional context like this. It makes code
hard to debug, etc. Could you change sky2_down to do the irq
cleanup before calling hw_down?

-- 
