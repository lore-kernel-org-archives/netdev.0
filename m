From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 3/5 v2] net/cpsw: don't rely only on netif_running() to
 check which device is active
Date: Mon, 22 Apr 2013 11:49:26 +0200
Message-ID: <517507A6.2090609@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de> <516FDE0A.70504@ti.com> <516FE2AD.2040403@linutronix.de> <51711E0B.4000306@ti.com> <20130422083048.GA8162@linutronix.de> <5174FF93.8070408@ti.com> <51750334.8050807@linutronix.de> <51750587.5020801@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56848 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab3DVJt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 05:49:28 -0400
In-Reply-To: <51750587.5020801@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2013 11:40 AM, Mugunthan V N wrote:
> Yes, when interrupt is disabled in hardware then interrupt must be
> disabled in
here is a word missing and I can't figure it out.

> my initial days i have verified it, CPSW doesn't allow any new
> interrupts to
> propagate  to arm if CPSW interrupt is disabled but there is an issue.
Not completed i.e. outstanding I think.

> CPSW irq
> signal is not directly connected to irq controller, it is connected via
> edge to
> level conversion so if one interrupt reaches arm, irq controller has to be
> disabled else arm get blocked in CPSW ISR.

Okay. Is there an errata document describing this behavior? If the CPSW
interrupt source is disabled, the CPSW should keep quiet. This is also
what the manual says. If cpsw does not allow new interrupts to
propagate to ARM's INTC then there is something wrong. It looks like
the source is not disabled in CPSW properly. This works on ES1.0.

Lets get back to this ofter this series of five is merged.

> Regards
> Mugunthan V N

Sebastian
