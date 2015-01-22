From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] tipc: fix excessive network event logging
Date: Thu, 22 Jan 2015 09:24:47 -0800
Message-ID: <1421947487.2702.1.camel@perches.com>
References: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0099.hostedemail.com ([216.40.44.99]:44132 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751930AbbAVRYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 12:24:51 -0500
In-Reply-To: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-22 at 17:10 +0100, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> If a large number of namespaces is spawned on a node and TIPC is
> enabled in each of these, the excessive printk tracing of network
> events will cause the system to grind down to a near halt.
> The traces are still of debug value, so instead of removing them
> completely we fix it by changing the link state and node availability
> logging debug traces.

Maybe some of these should be net_<level>_ratelimited(fmt, ...)

> diff --git a/net/tipc/link.c b/net/tipc/link.c
[]

> @@ -588,8 +588,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
>  				l_ptr->fsm_msg_cnt++;
>  				link_set_timer(l_ptr, cont_intv / 4);
>  			} else {	/* Link has failed */
> -				pr_warn("%s<%s>, peer not responding\n",
> -					link_rst_msg, l_ptr->name);

Like this one.

> +				pr_debug("%s<%s>, peer not responding\n",
> +					 link_rst_msg, l_ptr->name);
>  				tipc_link_reset(l_ptr);
>  				l_ptr->state = RESET_UNKNOWN;
>  				l_ptr->fsm_msg_cnt = 0;

> @@ -380,8 +380,8 @@ static void node_lost_contact(struct tipc_node *n_ptr)
>  	char addr_string[16];
>  	u32 i;
>  
> -	pr_info("Lost contact with %s\n",
> -		tipc_addr_string_fill(addr_string, n_ptr->addr));
> +	pr_debug("Lost contact with %s\n",
> +		 tipc_addr_string_fill(addr_string, n_ptr->addr));
>  
>  	/* Flush broadcast link info associated with lost node */
>  	if (n_ptr->bclink.recv_permitted) {

And maybe this one too.
