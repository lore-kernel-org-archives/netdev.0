From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 12:42:49 -0500 (EST)
Message-ID: <alpine.LFD.2.02.1112191231520.2907@xanadu.home>
References: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:53132 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435Ab1LSRmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 12:42:49 -0500
Received: from xanadu.home ([66.130.28.92]) by VL-VM-MR005.ip.videotron.ca
 (Oracle Communications Messaging Exchange Server 7u4-22.01 64bit (built Apr 21
 2011)) with ESMTP id <0LWG00M5HP73G5Q0@VL-VM-MR005.ip.videotron.ca> for
 netdev@vger.kernel.org; Mon, 19 Dec 2011 12:42:39 -0500 (EST)
In-reply-to: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Dec 2011, Mircea Gherzan wrote:

> +static inline void _emit(int cond, u32 inst, struct jit_ctx *ctx)
> +{
> +	if (ctx->target != NULL)
> +		ctx->target[ctx->idx] = inst | (cond << 28);
> +
> +	ctx->idx++;
> +}

You might consider the patch titled "ARM: Add generic instruction opcode 
manipulation helpers" that Dave Martin just posted and rely on it to 
make your code compatible with BE8 mode as well.

Also it seems that you are making the distinction between pre-ARMv7 and 
ARMv7+ while in most cases it should be pre-ARMv6 and ARMv6+


Nicolas
