From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Wed, 24 Mar 2004 11:52:09 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87lllrdkiu.fsf@ibmpc.myhome.or.jp>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com>
	<405DDDC6.7030007@pobox.com> <8765cvmyaq.fsf@devron.myhome.or.jp>
	<20040323195119.A14062@electric-eye.fr.zoreil.com>
	<871xnjgwrs.fsf@devron.myhome.or.jp>
	<20040324014140.A16202@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040324014140.A16202@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> writes:

> > Yes, maybe. But, if after spin_lock, it loop may call the twice
> > __netif_rx_schedule(). And netif_rx_complete() doesn't call dev_put().
> > It will leaks the dev->refcnt, I think.
> 
> @$*#!zW
> 
> The following patch should avoid the leak as well as the packet rot
> (untested, 1:33 AM, apply on top of previous serie).
> 
> 
> Multiple invocation of __netif_rx_schedule() in epic_interrupt() while
> epic_poll loops over __netif_rx_complete() leads to serious device
> refcount leak.

Do you care the lost interrupt? If so, I was miss reading it.

IIRC, PCI spec requires the level-trigger. So devices asserts IRQ
signal until the driver clears the pending interrupt. No?
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
