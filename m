From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] convert ircomm to seq_file interface
Date: Mon, 18 Aug 2003 13:09:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818200923.GC6577@bougret.hpl.hp.com>
References: <20030818123142.6369fbff.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030818123142.6369fbff.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2003 at 12:31:42PM -0700, Stephen Hemminger wrote:
> Convert ircomm /proc interface to seq_file.
> 
> Note: don't need spin_lock_irq because list is not ever locked
> from inside interrupt context.

	I don't agree with this change.
	If you look in ircomm_lmp.c ; ircomm_lmp_flow_control(), you
will see that the hashbin is accessed from BH context. So, at minimum
it should be a spin_lock_bh().
	Currently, all the IrDA stack uses spin_lock_irqsave(), where
is fact a only spin_lock_bh() is needed. But, this is something that I
kept for 2.7.X, because I would rather make sure previous locking
changes are safe, before going to the next step. So, for consistency
with the rest of the IrDA stack and the code in hashbin, I would keep
the spin_lock_irqsave().
	What do you think ?

	On the other hand, the conversion to seq_file is badly needed,
because the current /proc code was known to be very buggy. Thanks for
doing that.

	Have fun...

	Jean
