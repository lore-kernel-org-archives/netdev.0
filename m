From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] korina: fix deadlock on RX FIFO overrun
Date: Wed, 02 Jun 2010 06:12:32 -0700 (PDT)
Message-ID: <20100602.061232.190373991.davem@davemloft.net>
References: <20100529232343.ABC1D4CD45@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753207Ab0FBNMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:12:24 -0400
In-Reply-To: <20100529232343.ABC1D4CD45@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Sun, 30 May 2010 01:23:34 +0200

> By calling korina_restart(), the IRQ handler tries to disable the
> interrupt it's currently serving. This leads to a deadlock since
> disable_irq() waits for any running IRQ handlers to finish before
> returning. This patch addresses the issue by turning korina_restart()
> into a workqueue task, which is then scheduled when needed.
> 
> Reproducing the deadlock is easily done using e.g. GNU netcat to send
> large amounts of UDP data to the host running this driver.
> 
> Note that the same problem (and fix) applies to TX FIFO underruns, but
> apparently these are less easy to trigger.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied.
