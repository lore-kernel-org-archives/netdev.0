From: Alexander Viro <aviro@redhat.com>
Subject: Re: [PATCH] skfddi - convert to new pci model.
Date: Thu, 4 Dec 2003 19:59:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031205005915.GD31510@devserv.devel.redhat.com>
References: <20031204163928.0f34d5d1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Alexander Viro <aviro@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031204163928.0f34d5d1.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 04, 2003 at 04:39:28PM -0800, Stephen Hemminger wrote:
> +	dev->irq = pdev->irq;
>  	dev->get_stats = &skfp_ctl_get_stats;
>  	dev->open = &skfp_open;
>  	dev->stop = &skfp_close;
> +	dev->init = &skfp_driver_init;

Ehh...  Don't do that, please.  net_device ->init() means trouble,
since getting failure from register_netdev() gives you no clue
whether it had failed before, during or after ->init().  Makes
for an interesting cleanup...

You can do that if required cleanup can be deduced from the state
of *dev after register_netdev() failure (e.g. if no cleanup is
ever needed), but generally it's less PITA to just call the
damn function directly before register_netdev() and leave ->init NULL.
