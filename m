From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Deadlock in af_packet/packet_rcv
Date: Mon, 29 Nov 2004 20:02:20 -0800
Message-ID: <20041129200220.25ff3f7a.davem@davemloft.net>
References: <20041125205503.GA18083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041125205503.GA18083@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 25 Nov 2004 21:55:03 +0100
Olaf Kirch <okir@suse.de> wrote:

> Before introduction of lock-less loopback, all of netdev_xmit_nit was
> running with bottom halves disabled, and some code seems to rely on
> this. One of them is af_packet's packet_rcv handler, which is called
> from the receive path via netdev_xmit_nit.  It takes a spin lock,
> and if an interrupt occurs and calls netdev_xmit during this time,
> the CPU deadlocks.
> 
> The patch below disables BHs while in the TX path for loopback and
> similar devices.
>
> An alternative, less conservative fix would be to just use spin_lock_bh
> in af_packet.c.

Good spotting.

If it's only the dev_queue_xmit_nit() handlers which all want
BHs disabled, why don't we just disable BHs in that function?
