From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] net/cpsw: don't disable_irqs() after an interrupt has
 been received.
Date: Wed, 17 Apr 2013 09:44:44 +0200
Message-ID: <516E52EC.60901@linutronix.de>
References: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de> <516E3EED.4000200@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37781 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965776Ab3DQHor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 03:44:47 -0400
In-Reply-To: <516E3EED.4000200@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2013 08:19 AM, Mugunthan V N wrote:
> When using cpsw_intr_disable, it actually only disables future interrupts
> from CPSW ip. But the current interrupt generated to interrupt controller
> will be still pending and will not allow ARM to do any thing till either
> interrups is disabled or acked, thus CPU will be in CPSW ISR continuously
> and system will hang. This patch is applicable only when kernel is always
> built with RT enabled which is not the current case in Vanilla kernel

I am not talking about RT, just threaded interrupts but yes I saw the
problem first with RT.

> I have tested this patch and it hangs the CPU after net open (CPSW init).

If I remove additionally the napi_schedule() piece then the network is
dead (as expected) and the system continues to work (and I receive
interrupts) and the ISR for cpsw is not executed again. What hardware /
CPU do you have?

> 
> Regards
> Mugunthan V N

Sebastian
