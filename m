From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Fri, 8 Oct 2004 16:53:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008215303.GD31237@waste.org>
References: <20041006234912.66bfbdcc.davem@davemloft.net> <20041007160532.60c3f26b@pirandello> <20041007112846.5c85b2d9.davem@davemloft.net> <20041007224422.1c1bea95@jack.colino.net> <20041007214505.GB31558@wotan.suse.de> <20041007215025.GT31237@waste.org> <20041007150756.2373719f.davem@davemloft.net> <20041007234322.GW31237@waste.org> <20041007235022.GB19864@wotan.suse.de> <20041008084640.58976145@pirandello>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Colin Leroy <colin@colino.net>
Content-Disposition: inline
In-Reply-To: <20041008084640.58976145@pirandello>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 08, 2004 at 08:46:40AM +0200, Colin Leroy wrote:
> On 08 Oct 2004 at 01h10, Andi Kleen wrote:
> 
> Hi, 
> 
> > > Deadlocks from recursion, presumably? We could probably throw in a
> > > max retry count, as ugly as that is..
> > 
> > There should not be any recursion, no.
> 
> If printk() is synchronous, there could be, if there's a printk() in the
> codepath taken by dev->hard_start_xmit()... But I don't if it is...

Have you looked at the code path that does carrier detect for possibly
recursing printks?

> > For most network drivers this shouldn't occur though because
> > the net driver private lock is usually always taken with interrupts
> > off. 
> 
> Second newbie question: how are the interrupts disabled, is it via
> local_irq_save()/local_irq_restore()? or is it something else ?

Often by virtue of being in an interrupt context already.

-- 
Mathematics is the supreme nostalgia of our time.
