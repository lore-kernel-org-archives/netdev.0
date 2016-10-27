From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: Bug in cadence macb driver
Date: Thu, 27 Oct 2016 11:05:16 +0200
Message-ID: <1da8552b-a7e8-0850-31ce-f608504b01a1@atmel.com>
References: <3DDE7A42-84A6-44DC-9919-C0D9166E87EF@workware.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Steve Bennett <steveb@workware.net.au>, <netdev@vger.kernel.org>,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:30920 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752275AbcJ0JNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 05:13:00 -0400
In-Reply-To: <3DDE7A42-84A6-44DC-9919-C0D9166E87EF@workware.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/10/2016 à 09:22, Steve Bennett a écrit :
> Hi,
> 
> We are seeing the following problem in the cadence macb driver.
> 
> BUG: scheduling while atomic: kworker/0:1/44/0x00000002
> Modules linked in: 8021q of_serial beacon_sigproc io_processor emsattr ems_dma_fifo xaxi_dma libgpioreg leds_gpio
> CPU: 0 PID: 44 Comm: kworker/0:1 Not tainted 4.4.0 #1
> Hardware name: Xilinx Zynq Platform
> Workqueue: events macb_tx_error_task
> [<c0016a18>] (unwind_backtrace) from [<c0012ad4>] (show_stack+0x10/0x14)
> [<c0012ad4>] (show_stack) from [<c01b089c>] (dump_stack+0x88/0xd8)
> [<c01b089c>] (dump_stack) from [<c008e94c>] (__schedule_bug+0x48/0x60)
> [<c008e94c>] (__schedule_bug) from [<c03592d4>] (__schedule+0x80/0x4c4)
> [<c03592d4>] (__schedule) from [<c0359968>] (schedule+0xac/0xd4)
> [<c0359968>] (schedule) from [<c035c284>] (schedule_hrtimeout_range_clock+0xc0/0xf4)
> [<c035c284>] (schedule_hrtimeout_range_clock) from [<c035bebc>] (usleep_range+0x44/0x48)
> [<c035bebc>] (usleep_range) from [<c025ec48>] (macb_tx_error_task+0xa0/0x270)
> [<c025ec48>] (macb_tx_error_task) from [<c0035b6c>] (process_one_work+0x1b8/0x2f0)
> [<c0035b6c>] (process_one_work) from [<c0035fb4>] (worker_thread+0x2e4/0x3f0)
> [<c0035fb4>] (worker_thread) from [<c003ac94>] (kthread+0xdc/0xf0)
> [<c003ac94>] (kthread) from [<c000f698>] (ret_from_fork+0x14/0x3c)
> 
> Here we are running at 10M half duplex, so tx is slow.
> The problem was introduced in e4bfd971b where a spinlock is taken before

I can't find this commit ID. Can you please give the one on Linus' tree
together with the commit subject?

Thanks,

> calling macb_halt_tx() which may then sleep waiting for the current packet to finish
> transmitting.
> 
> We don't need the spinlock on our platform since we don't have multiple queues, but
> this should be fixed properly in the general case.
> 
> Cheers,
> Steve
> 
> --
> µWeb: Embedded Web Framework - http://uweb.workware.net.au/
> WorkWare Systems Pty Ltd
> W: www.workware.net.au      P: +61 434 921 300
> E: steveb@workware.net.au
> 
> 
> 
> 
> 
> 


-- 
Nicolas Ferre
