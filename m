From: Jason Baron <jbaron@redhat.com>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Thu, 6 Sep 2012 13:51:58 -0400
Message-ID: <20120906175158.GB9786@redhat.com>
References: <cover.1345978012.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1345978012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 26, 2012 at 04:25:25AM -0700, Joe Perches wrote:
> The recent commit to fix dynamic_debug was a bit unclean.
> Neaten the style for dynamic_debug.
> Reduce the stack use of message logging that uses netdev_printk
> Add utility functions dev_printk_emit and dev_vprintk_emit for /dev/kmsg.
> 
> Joe Perches (5):
>   dev_dbg/dynamic_debug: Update to use printk_emit, optimize stack
>   netdev_printk/dynamic_netdev_dbg: Directly call printk_emit
>   netdev_printk/netif_printk: Remove a superfluous logging colon
>   dev: Add dev_vprintk_emit and dev_printk_emit
>   device and dynamic_debug: Use dev_vprintk_emit and dev_printk_emit
> 

Looks Good.

The one thing that is bothering me though, is that for
__dynamic_dev_dbg(), __dynamic_netdev_dbg(), we are copying much of the core
logic of __dev_printk(), __netdev_printk(), respectively. I would prefer
have this in one place. Can we add a 'prefix' argument to __dev_printk(),
and __netdev_printk() that dynamic debug can use, but is simply empty
for dev_printk() and netdev_printk().

Thanks,

-Jason
