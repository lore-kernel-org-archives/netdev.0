From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.X] 32->64 bit conversion for wireless private ioctl
Date: Thu, 24 Jun 2004 20:15:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625001557.GA19939@havoc.gtf.org>
References: <20040624234307.GA5514@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Andi Kleen <ak@suse.de>,
        Pavel Machek <pavel@suse.cz>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20040624234307.GA5514@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 24, 2004 at 04:43:07PM -0700, Jean Tourrilhes wrote:
> 	Hi all,
> 
> 	(Sorry for the spam)
> 
> 	The Wireless Extensions use a bunch of driver specific
> ioctl. Jeff told me that those can't be safe when running a 32 bit
> userspace on a 64 bit kernel. So, I did a patch...
> 	Patch is for kernel 2.6.5.
> 
> 	Treat this patch as a proof of concept. I don't have any 64
> bit machine, so no way to compile it (without talking of actually
> testing it). But this is where I hope you guys will help me ;-)

You missed what I was trying to communicate :(

It is a logical contradiction to create a generic interface for
driver-private ioctls.  You wind up re-inventing Sun XDR.


> +	/* Get the description of the IOCTL */
> +	for(i = 0; i < dev->wireless_handlers->num_private_args; i++)
> +		if(cmd == dev->wireless_handlers->private_args[i].cmd) {
> +			descr = &(dev->wireless_handlers->private_args[i]);
> +			break;

This is essentially runtime definition of structures types.

We want to go in the opposite direction:  compile and verify as much
code as possible at compile time.  Strong, compile-time type checking.

	Jeff
