From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: MSI interrupts and disable_irq
Date: Tue, 02 Oct 2007 21:03:34 +0200
Message-ID: <47029606.1080104@colorfullife.com>
References: <46FC15A9.1070803@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, nedev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ev1s-75-125-39-150.ev1servers.net ([75.125.39.150]:37709 "EHLO
	colorfullife.mysite.adiungo.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752342AbXJBUHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 16:07:09 -0400
In-Reply-To: <46FC15A9.1070803@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> I am trying to track down a forcedeth driver issue described by bug 
> 9047 in bugzilla (2.6.23-rc7-git1 forcedeth w/ MCP55 oops under heavy 
> load). I added a patch to synchronize the timer handlers so that one 
> handler doesn't accidently enable the IRQ while another timer handler 
> is running (see attachment 'Add timer lock' in bug report) and for 
> other processing protection.
>
> However, the system still had an Oops. So I added a lock around the 
> nv_rx_process_optimized() and the Oops has not happened (see 
> attachment 'New patch for locking' in bug report). This would imply a 
> synchronization issue. However, the only callers of that function are 
> the IRQ handler and the timer handlers (in non-NAPI case). The timer 
> handlers  use disable_irq so that the IRQ handler does not contend 
> with them. It looks as if disable_irq is not working properly.
Either disable_irq() is not working properly or interrupts are nested, 
i.e. the irq handler is called again while running.
Which timer handler do you mean? I only see disable_irq() in the 
configuration paths (set mtu, change ring size, ...) and in the tx 
timeout case.
Neither one should happen during normal operation.

--
    Manfred
