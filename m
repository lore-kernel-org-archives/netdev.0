From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 7 Mar 2016 16:48:14 +0100
Message-ID: <56DDA2BE.7050800@linutronix.de>
References: <56D1E8B6.6090003@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Peter Hurley <peter@hurleysoftware.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:45535 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbcCGPsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 10:48:17 -0500
In-Reply-To: <56D1E8B6.6090003@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2016 07:19 PM, Peter Hurley wrote:
> Hi Eric,

Hi Peter,

> Because both the uart driver (omap8250) and the dmaengine driver
> (edma) were (relatively) new, we assumed there was some race between
> starting a new rx DMA and processing the previous one.

Now after digesting the whole thread. I complained about this a long
while ago. After you start RX-DMA the DMA-engine is not programmed
immediately but deferred into softirq/tasklet. This is not the case for
continuous DMA transfer - those are programmed right away.

I don't remember that I found a reason why this simple programming has
to be deferred and can't happen immediately like it is the case for the
continuous DMA transfers. So I skipped that. RX-DMA in UART was working
well but for some reason omap's MMC-card driver refused to work.

Sebastian
