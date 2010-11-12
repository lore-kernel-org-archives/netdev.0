From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: request_threaded_irq()
Date: Fri, 12 Nov 2010 08:35:26 -0800
Message-ID: <20101112083526.1c3784b1@nehalam>
References: <AANLkTikCQRiW3oWYSXK7yTxLWd3us+8wdwfuOs1k71VD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Ryden <markryde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51996 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932557Ab0KLQf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Nov 2010 11:35:28 -0500
In-Reply-To: <AANLkTikCQRiW3oWYSXK7yTxLWd3us+8wdwfuOs1k71VD@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Nov 2010 14:27:11 +0200
Mark Ryden <markryde@gmail.com> wrote:

> Hello netdev,
> 
> grepping under net-next-2.6/drivers/net for request_threaded_irq() ,
> shows that it appears only in 3 drivers:
> 
> can/mcp251x.c
> wireless/b43/main.c
> wireless/rt2x00/rt2x00pci.c
> 
> I was wondering: when thinking about performance, is it worthwhile to use this
> API instead of ordinary request_irq() . It seems to me that
> request_threaded_irq()  might
> be better in some cases than NAPI polling forr network drivers (or at
> list it might be so in some systems, maybe multicore ?)

Threaded irq is not needed for properly written NAPI driver.
A NAPI driver should do minimum work in real irq and the whole NAPI processing
will happen in soft-irq.

There has been discussion of moving NAPI softirq into a high
priority thread. But last time I tried it, the performance was noticably
worse on network intensive benchmarks.

