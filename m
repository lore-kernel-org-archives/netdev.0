From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [NET]: TSO requires SG, enforce this at device registry.
Date: Mon, 25 Oct 2004 01:50:41 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <417C9431.6030505@pobox.com>
References: <200410221715.i9MHFlIu021927@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261437AbUJYFvA@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <200410221715.i9MHFlIu021927@hera.kernel.org>
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> diff -Nru a/net/core/dev.c b/net/core/dev.c
> --- a/net/core/dev.c	2004-10-22 10:15:57 -07:00
> +++ b/net/core/dev.c	2004-10-22 10:15:57 -07:00
> @@ -2871,6 +2871,14 @@
>  		dev->features &= ~NETIF_F_SG;
>  	}
>  
> +	/* TSO requires that SG is present as well. */
> +	if ((dev->features & NETIF_F_TSO) &&
> +	    !(dev->features & NETIF_F_SG)) {
> +		printk("%s: Dropping NETIF_F_TSO since no SG feature.\n",
> +		       dev->name);
> +		dev->features &= ~NETIF_F_TSO;
> +	}


Although this patch is correct, I am pondering whether this fully covers 
the problems in the field.

There are currently two classes of problems I am seeing, that generate 
real-life bug reports:

1) Given current driver implementations of ethtool ioctls, sysadmin is 
free to create a combination of bits that are IMHO a bug.  One can argue 
that this is an extension of "root can shoot himself in the foot", so 
who knows.

2) Programmers writing drivers do not appear to be clear that SG is 
required to tx-csum/tso, and also, should not be present without one or 
both of those bits set.

	Jeff
