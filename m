From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Fri, 8 Oct 2004 08:46:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008084640.58976145@pirandello>
References: <20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007160532.60c3f26b@pirandello>
	<20041007112846.5c85b2d9.davem@davemloft.net>
	<20041007224422.1c1bea95@jack.colino.net>
	<20041007214505.GB31558@wotan.suse.de>
	<20041007215025.GT31237@waste.org>
	<20041007150756.2373719f.davem@davemloft.net>
	<20041007234322.GW31237@waste.org>
	<20041007235022.GB19864@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, "David S. Miller" <davem@davemloft.net>,
        ak@suse.de, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041007235022.GB19864@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 08 Oct 2004 at 01h10, Andi Kleen wrote:

Hi, 

> > Deadlocks from recursion, presumably? We could probably throw in a
> > max retry count, as ugly as that is..
> 
> There should not be any recursion, no.

If printk() is synchronous, there could be, if there's a printk() in the
codepath taken by dev->hard_start_xmit()... But I don't if it is...

> The problem is that the poll is effectively a spinlock. But when
> another CPU takes an long interrupt while holding the lock it 
> could take quite a long time to grab the lock.
> 
> For most network drivers this shouldn't occur though because
> the net driver private lock is usually always taken with interrupts
> off. 

Second newbie question: how are the interrupts disabled, is it via
local_irq_save()/local_irq_restore()? or is it something else ?

-- 
Colin
