From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] Deadlock in af_packet/packet_rcv
Date: Tue, 30 Nov 2004 10:32:31 +0100
Message-ID: <41AC3E2F.2030003@tpack.net>
References: <20041125205503.GA18083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041125205503.GA18083@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Olaf Kirch wrote:
> Before introduction of lock-less loopback, all of netdev_xmit_nit was
> running with bottom halves disabled, and some code seems to rely on
> this. One of them is af_packet's packet_rcv handler, which is called
> from the receive path via netdev_xmit_nit.  It takes a spin lock,
> and if an interrupt occurs and calls netdev_xmit during this time,
> the CPU deadlocks.

An interrupt handler shouldn't call dev_queue_xmit() directly. If
this indeed happens, it needs to be fixed. Which handler is this?

> The patch below disables BHs while in the TX path for loopback and
> similar devices.

dev_queue_xmit() already have BHs disabled, so this won't do anything.
And weren't you talking about interrupts ??

Protocol handlers are called with bottom halves disabled, but IRQs
are enabled. This hasn't changed - and is assumed in lots of places.

-Tommy
