From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 16:30:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031105163025.796cc462.shemminger@osdl.org>
References: <Pine.LNX.4.44.0311051558350.1359-100000@DYN318430BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0311051558350.1359-100000@DYN318430BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
> diff -ruN linux-2.6.0-test9-bk9/net/core/dev.c linux-2.6.0-test9-bk9.new/net/core/dev.c
> --- linux-2.6.0-test9-bk9/net/core/dev.c	2003-11-05 15:43:21.000000000 -0800
> +++ linux-2.6.0-test9-bk9.new/net/core/dev.c	2003-11-05 15:43:50.000000000 -0800
> @@ -2749,8 +2749,10 @@
>  			rtnl_exlock();
> 
>  			/* Rebroadcast unregister notification */
> +			dev_hold(dev);
>  			notifier_call_chain(&netdev_chain,
>  					    NETDEV_UNREGISTER, dev);
> +			dev_put(dev);
> 
>  			if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
>  				     &dev->state)) {
> 

Hey, what if the dev refcount goes to zero before your dev_hold?
Actually this repeated notifier looks like it wouldn't work anyway.
Why would a protocol drop it's reference when notified a second time?

I would argue even running the loop once means some protocol is busted.
