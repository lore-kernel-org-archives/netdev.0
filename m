From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/5 v2] net/cpsw: don't rely only on netif_running() to
 check which device is active
Date: Mon, 22 Apr 2013 15:42:43 +0530
Message-ID: <51750D1B.4060600@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de> <516FDE0A.70504@ti.com> <516FE2AD.2040403@linutronix.de> <51711E0B.4000306@ti.com> <20130422083048.GA8162@linutronix.de> <5174FF93.8070408@ti.com> <51750334.8050807@linutronix.de> <51750587.5020801@ti.com> <517507A6.2090609@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:36139 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119Ab3DVKNd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 06:13:33 -0400
In-Reply-To: <517507A6.2090609@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/2013 3:19 PM, Sebastian Andrzej Siewior wrote:
> On 04/22/2013 11:40 AM, Mugunthan V N wrote:
>> Yes, when interrupt is disabled in hardware then interrupt must be
>> disabled in
> here is a word missing and I can't figure it out.
>
>> my initial days i have verified it, CPSW doesn't allow any new
>> interrupts to
>> propagate  to arm if CPSW interrupt is disabled but there is an issue.
> Not completed i.e. outstanding I think.
>
>> CPSW irq
>> signal is not directly connected to irq controller, it is connected via
>> edge to
>> level conversion so if one interrupt reaches arm, irq controller has to be
>> disabled else arm get blocked in CPSW ISR.
> Okay. Is there an errata document describing this behavior? If the CPSW
> interrupt source is disabled, the CPSW should keep quiet. This is also
> what the manual says. If cpsw does not allow new interrupts to
> propagate to ARM's INTC then there is something wrong. It looks like
> the source is not disabled in CPSW properly. This works on ES1.0.
>
> Lets get back to this ofter this series of five is merged.
>
Sorry there was a formatting issue...

Yes, when interrupt is disabled in hardware then interrupt must be disabled.
In my initial days i have verified it, CPSW doesn't allow any new 
interrupts to
propagate  to arm if CPSW interrupt is disabled which is correct. CPSW irq
signal is not directly connected to irq controller, it is connected via 
edge to
level conversion so it is a kind of latched interrupt and so the 
interrupt has
to be disabled in interrupt controller to disable the interrupt, else 
arm get
blocked in CPSW ISR.

This behavior is not only in AM335x CPSW, it is as is from its previous
versions in TI814x and TI8107.

Regards
Mugunthan V N
