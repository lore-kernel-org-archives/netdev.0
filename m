From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/3] SSB EXTIF timing & serial port initialization
Date: Mon, 6 Aug 2007 20:23:07 +0200
Message-ID: <200708062023.08046.mb@bu3sch.de>
References: <20070806150447.GB24308@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Felix Fietkau <nbd@openwrt.org>
To: Aurelien Jarno <aurelien@aurel32.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:58975
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755924AbXHFSXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 14:23:11 -0400
In-Reply-To: <20070806150447.GB24308@hall.aurel32.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 06 August 2007, Aurelien Jarno wrote:
> The patch below adds a new file drivers/ssb/driver_extif.c which
> contains new SSB EXTIF functions to initializes the timing and the
> serial ports.
> 
> Cc: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>

> +#ifdef CONFIG_SSB_SERIAL
> +static bool serial_exists(u8 *regs)
> +{
> +	u8 save_mcr, msr = 0;
> +
> +	if (regs) {
> +		save_mcr = regs[UART_MCR];
> +		regs[UART_MCR] = (UART_MCR_LOOP | UART_MCR_OUT2 | UART_MCR_RTS);
> +		msr = regs[UART_MSR] & (UART_MSR_DCD | UART_MSR_RI \
                                                                 ^^^^^
Backslash?

> +					| UART_MSR_CTS | UART_MSR_DSR);
> +		regs[UART_MCR] = save_mcr;
> +	}
> +	return (msr == (UART_MSR_DCD | UART_MSR_CTS));
> +}
