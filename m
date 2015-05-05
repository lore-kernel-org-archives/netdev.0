From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: call local_irq_save other than disable_irq in
 poll_controller
Date: Tue, 05 May 2015 19:36:33 -0400 (EDT)
Message-ID: <20150505.193633.2161230945632055751.davem@davemloft.net>
References: <1430812553-7588-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278AbbEEXgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:36:35 -0400
In-Reply-To: <1430812553-7588-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Tue, 5 May 2015 15:55:53 +0800

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> It is possible that poll_controller is called from netpoll.c with irq
> already disabled. Unexpected interrupt may be triggered if always
> enable irq before returning from poll_controller.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>

Nope, this is wrong.

If you don't use disable_irq(), the interrupt handler can run in
parallel on another cpu and you definitely do not want that.

There is nothing wrong with the interrupt triggering on the
enable_irq() here.  If that causes some problem, there is a
bug in this driver.
