From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.35-rc3-git7] axnet_cs: local_irq_save before
 calling ei_irq_wrapper
Date: Wed, 07 Jul 2010 14:51:12 -0700 (PDT)
Message-ID: <20100707.145112.216750350.davem@davemloft.net>
References: <20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
	<20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
	<20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53016
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758021Ab0GGVu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 17:50:58 -0400
In-Reply-To: <20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Tue, 6 Jul 2010 20:22:43 +0900

> 
> axnet_cs:
>     local_irq_save before calling ei_irq_wrapper.
> 
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

An interrupt handler may not assume that interrupts are disabled when
it is invoked.

The axnet_interrupt() code needs to be fixed to use
spin_lock_irqsave() et al.

Then, this change of your's is no longer needed.
