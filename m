From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Followup to netpoll issues
Date: Fri, 7 Jan 2005 23:41:55 +0100
Message-ID: <20050107224155.GB17317@electric-eye.fr.zoreil.com>
References: <1105045914.7687.3.camel@tigger> <20050106234610.GT2940@waste.org> <20050107011547.GE27896@electric-eye.fr.zoreil.com> <20050107170118.GU2940@waste.org> <20050107214254.GA17317@electric-eye.fr.zoreil.com> <20050107220723.GB2940@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Broadbent <markb@wetlettuce.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20050107220723.GB2940@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall <mpm@selenic.com> :
[...]
> > Sorry if I was not clear: "from anywhere" meant printk issued from
> > any part of the kernel which can interrupt the xmit_locked section
> > of a qdisc_run(), i.e. printk from irq handlers. 
> 
> Hrmm. Yes, that's uglier than I realized.
> 
> Perhaps there's a way to use the existing IRQ handler reentrancy
> avoidance to detect that we might be about to recurse on a lock.

It would help if qdisc_restart() disabled irq until xmit_lock_owner
is set (an extra memory barrier would be required btw). 

I'd say to go with in_irq() + try_lock() but one could object that
try_lock() leaves a window where a late thread could steal the
lock.

--
Ueimor
