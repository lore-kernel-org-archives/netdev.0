From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] netlink functions that can be static (trivial)
Date: Wed, 28 Apr 2004 12:25:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040428122535.4f30f1b0.davem@redhat.com>
References: <20040428104853.229f3d6c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040428104853.229f3d6c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Apr 2004 10:48:53 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Several internal functions and tables in rtnetlink can be static, and
> fill functions don't change stat of the net_device.

Some problems here...


> -static int rtnetlink_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
> +static int rtnetlink_fill_ifinfo(struct sk_buff *skb,
> +				 const struct net_device *dev,

It doesn't start as static in my tree, I think you diffed the wrong
revisions in your tree. :-)  We export this thing to modules too, how
do you know some external module doesn't actually use this thing?  I
know of no users, but...

> -	struct net_device *dev;
> +	const struct net_device *dev;

This is wrong, a few lines down we assign it here:

>  	read_lock(&dev_base_lock);
>  	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {

So marking that 'dev' const cannot be right.  Or are you marking the
"object pointed to by 'dev'" as const?

The rest of the patch seems fine, just clean these two things up.
Thanks.
