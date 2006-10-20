From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 14:41:53 -0700
Message-ID: <20061020144153.2bbeaf9d@dxpl.pdx.osdl.net>
References: <20061020.134209.85688168.davem@davemloft.net>
	<200610202301.29859.ak@suse.de>
	<20061020.140859.95896187.davem@davemloft.net>
	<200610202316.03940.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3972 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992753AbWJTVmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:42:14 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200610202316.03940.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Oct 2006 23:16:03 +0200
Andi Kleen <ak@suse.de> wrote:

> On Friday 20 October 2006 23:08, David Miller wrote:
> > From: Andi Kleen <ak@suse.de>
> > Date: Fri, 20 Oct 2006 23:01:29 +0200
> > 
> > > netpoll always played a little fast'n'lose with various locking rules.
> > 
> > The current code is fine, it never reenters ->poll, because it
> > maintains a "->poll_owner" which it checks in netpoll_send_skb()
> > before trying to call back into ->poll.
> 
> I was more thinking of reentry of the interrupt handler in 
> the driver etc. A lot of them also do printk, but that is fortunately
> caught higher level.
> 
> -Andi

One problem is that with netconsole the NAPI poll routine can be
called with IRQ's disabled. This means that calls to dev_kfree_skb()
are incorrect in this context. The driver would have to use dev_kfree_skb_any()
instead.
