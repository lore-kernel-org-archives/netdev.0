From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/32] [TIPC] Multicast link failure now resets all links
 to "nacking" node.
Date: Thu, 22 Jun 2006 14:51:29 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606221448060.21897@d.namei>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
 <1150984785859-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:26853 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161182AbWFVSvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 14:51:32 -0400
To: Per Liden <per.liden@ericsson.com>
In-Reply-To: <1150984785859-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Jun 2006, Per Liden wrote:

> +static void link_reset_all(unsigned long addr)
> +{
> +	struct node *n_ptr;
> +	char addr_string[16];
> +	u32 i;
> +
> +	read_lock_bh(&tipc_net_lock);
> +	n_ptr = tipc_node_find((u32)addr);
> +	if (!n_ptr) {
> +		read_unlock_bh(&tipc_net_lock);
> +		return;	/* node no longer exists */
> +	}
> +
> +	tipc_node_lock(n_ptr);

You already have bh's disabled here, and tipc_node_lock() also disables 
them.

Not sure if it's really worth worrying about but if so, you could perhaps 
implement tipc_node_lock_bh() and tipc_node_lock().



- James
-- 
James Morris
<jmorris@namei.org>
