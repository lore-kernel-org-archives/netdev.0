From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Thu, 30 Aug 2012 11:25:21 -0700
Message-ID: <1346351121.2103.36.camel@joe2Laptop>
References: <cover.1345978012.git.joe@perches.com>
	 <CAJfuBxyQc-XeNHxw0_XDs0JuCrNArNzcgsmrLya4ncDvSojZxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@redhat.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org
To: Jim Cromie <jim.cromie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJfuBxyQc-XeNHxw0_XDs0JuCrNArNzcgsmrLya4ncDvSojZxQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-30 at 11:43 -0600, Jim Cromie wrote:
> On Sun, Aug 26, 2012 at 5:25 AM, Joe Perches <joe@perches.com> wrote:
> > The recent commit to fix dynamic_debug was a bit unclean.
> > Neaten the style for dynamic_debug.
> > Reduce the stack use of message logging that uses netdev_printk
> > Add utility functions dev_printk_emit and dev_vprintk_emit for /dev/kmsg.
> >
> > Joe Perches (5):
> >   dev_dbg/dynamic_debug: Update to use printk_emit, optimize stack
> >   netdev_printk/dynamic_netdev_dbg: Directly call printk_emit
> >   netdev_printk/netif_printk: Remove a superfluous logging colon
> >   dev: Add dev_vprintk_emit and dev_printk_emit
> >   device and dynamic_debug: Use dev_vprintk_emit and dev_printk_emit
> >
> 
> Ive tested this on 2 builds differing only by DYNAMIC_DEBUG
> It works for me on x86-64
> 
> However, I just booted a non-dyndbg build on x86-32, and got this.
> 
> 
> root@voyage:~# dmesg | grep Unknown
> mac80211: Unknown symbol __dynamic_dev_dbg (err 0)
> mac80211: Unknown symbol __dynamic_pr_debug (err 0)
> scx200_acb: Unknown symbol __dynamic_dev_dbg (err 0)
> scx200_acb: Unknown symbol __dynamic_pr_debug (err 0)
> hwmon: Unknown symbol __dynamic_dev_dbg (err 0)
> nsc_gpio: Unknown symbol __dynamic_dev_dbg (err 0)
> nsc_gpio: Unknown symbol __dynamic_dev_dbg (err 0)
> root@voyage:~#
> 
> It may be my error, will investigate asap,
> but wanted to report now.

Thanks, but I don't know how this is possible.
There are no 32/64 component tests in this code.
