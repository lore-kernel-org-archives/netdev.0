From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] (13/23) sk98: handle ring full correctly
Date: 12 Nov 2004 11:54:48 +0100
Message-ID: <1100256887.22136.26.camel@cyan.cph.tpack.net>
References: <4192C60A.1050205@designassembly.de>
	 <20041111154225.5cf85567@zqx3.pdx.osdl.net>
	 <20041111160008.005fbca5@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041111160008.005fbca5@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-11-12 at 01:00, Stephen Hemminger wrote:
> This driver needs to manage it's transmit queue properly.
> The hard_start_xmit needs to return OK if send successfully
> and BUSY (1) if queue is full. In either case must free skb,
> existing code would leak if tx ring filled!

This isn't true. When returning NETDEV_TX_BUSY, the caller
will requeue or drop the skb. So

> +	/* Transmit failed, out of resources */
> +	if (rc < 0) {
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_BUSY;
> +	} else {
> +		dev->trans_start = jiffies;		
> +		return NETDEV_TX_OK;
> +	}

it shouldn't be freed here.

-Tommy
