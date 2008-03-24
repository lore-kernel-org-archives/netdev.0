From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Fix lockdep problems with sge.reg_lock
Date: Mon, 24 Mar 2008 14:14:58 -0700
Message-ID: <47E819D2.9040805@chelsio.com>
References: <adabq59xhmv.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Felix Marti <felix@chelsio.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11834 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbYCXVPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 17:15:10 -0400
In-Reply-To: <adabq59xhmv.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> Using iWARP with a Chelsio T3 NIC generates the following lockdep warning:
>
>     =================================
>     [ INFO: inconsistent lock state ]
>     2.6.25-rc6 #50
>     ---------------------------------
>     inconsistent {softirq-on-W} -> {in-softirq-W} usage.
>     swapper/0 [HC0[0]:SC1[1]:HE0:SE0] takes:
>      (&adap->sge.reg_lock){-+..}, at: [<ffffffff880e5ee2>] cxgb_offload_ctl+0x3af/0x507 [cxgb3]
>
> The problem is that reg_lock is used with plain spin_lock() in
> drivers/net/cxgb3/sge.c but is used with spin_lock_irqsave() in
> drivers/net/cxgb3/cxgb3_offload.c.  This is technically a false
> positive, since the uses in sge.c are only in the initialization and
> cleanup paths and cannot overlap with any use in interrupt context.
>
> The best fix is probably just to use spin_lock_irq() with reg_lock in
> sge.c.  Even though it's not strictly required for correctness, it
> avoids triggering lockdep and the extra overhead of disabling
> interrupts is not important at all in the initialization and cleanup
> slow paths.
>
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
>   
Acked-by: Divy Le Ray <divy@chelsio.com>

As you mention, the current code is correct even if lockdep disagrees.


Cheers,
Divy
