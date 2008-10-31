From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Fri, 31 Oct 2008 23:28:24 +0300
Message-ID: <20081031202824.GA32720@ioremap.net>
References: <1225450706.5301.94.camel@localhost> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:42520 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbYJaU20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 16:28:26 -0400
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 10:07:58AM -0700, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> > > Also, you've got a potential threading issue - you're not protecting
> > > the frame index behind the spinlock.
> > 
> > You are right, I think I will spin-lock outside the do_while loop.
> Can't do that I think - dev_queue_xmit sleeps AFAIK and you can't hold a spinlock when you sleep.

It does not and can be called from interrupt context, but interrupts
have to be turned on, since BH will be reenabled there.

>Can you explain why you need a spinlock though?  I think you're trying to make it thread-safe if multiple threads make calls to send, correct?  In this case, just change it to a semaphore, and protect the entire send call (well - at least in a safe enough way to make sure you're properly unlocking upon exit).  Also, a better question is - is there any particular reason we need to support multiple threads calling send?  Just stipulate that the behaviour is undefined when there are calls to send from different threads.

If there will be no synchronization you should very carefully call
udnerlying functions not to race against each other. For example
device queue should be locked.

-- 
	Evgeniy Polyakov
