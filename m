From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tilepro ethernet driver: fix a few minor issues
Date: Tue, 03 Apr 2012 18:23:35 -0400 (EDT)
Message-ID: <20120403.182335.782073108961783777.davem@davemloft.net>
References: <201203302325.q2UNPm8j012403@farm-0012.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201203302325.q2UNPm8j012403@farm-0012.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Fri, 30 Mar 2012 19:23:35 -0400

> This commit fixes a number of issues seen with the driver:
> 
> - Improve handling of return credits to the hardware shim
> - Use skb_frag_size() appropriately
> - Add netpoll support to run console over UDP
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Please do not mix pure bug fixes and new features.

Submit the pure bug fixes separately for 'net' tree submission
and then submit feature additions like netpoll support in
a patch targetting the 'net-next' tree.

> +	/* Handle completions if needed to make room. */
> +	/* NOTE: Return NETDEV_TX_BUSY if there is still no room. */

Do not format comments like this, use something like this instead:

	/* Handle completions if needed to make room.
	 * NOTE: Return NETDEV_TX_BUSY if there is still no room.
	 */

>  	/* Prepare to advance, detecting full queue. */
> +	/* NOTE: Return NETDEV_TX_BUSY if the queue is full. */

Similarly, combine them up into a single comment.

> +	/* Handle completions if needed to make room. */
> +	/* NOTE: Return NETDEV_TX_BUSY if there is still no room. */

Same here.

>  	/* Copy the commands, or fail. */
> +	/* NOTE: Return NETDEV_TX_BUSY if the queue is full. */

Again.

> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +/*
> + * Polling 'interrupt' - used by things like netconsole to send skbs

Format the comment:

	/* Like
	 * this.
	 */

not:

	/*
	 * Like
	 * this.
	 */
