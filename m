From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT] netif_queue_stopped in TBF scheduler
Date: Fri, 18 Jun 2004 13:51:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618135139.58d03876.davem@redhat.com>
References: <58D550446979A646A05649BF9EAF113AA2E995@orsmsx407>
	<20040617155603.0651081c@dell_ss3.pdx.osdl.net>
	<20040617160930.729b35ad@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040617160930.729b35ad@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 16:09:30 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> There is a race between the device and scheduler if the scheduler looks
> at netif_queue_stopped.  What can happen is that the device decides it is ready,
> just after the stopped check, and the scheduler decides it is throttled.
> 
> The simple way is to just have the scheduler always dequeue and leave the flow
> control up to the driver and the core scheduling loop.

CBQ, HFSC, etc. etc. have this same logic too.

I agree, the flow control should be handled at the top level by
qdisc_restart(), and it does by invoking ->requeue() if the xmit
fails at the device level or it cannot obtain the necessary locks.

I'm going to make this fix across the board.
