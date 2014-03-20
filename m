From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 1/4] openvswitch: split flow structures into
 ovs specific and generic ones
Date: Thu, 20 Mar 2014 13:04:26 +0000
Message-ID: <20140320130426.GF16640@casper.infradead.org>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <1395243232-32630-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36554 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755261AbaCTNEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 09:04:30 -0400
Content-Disposition: inline
In-Reply-To: <1395243232-32630-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/14 at 04:33pm, Jiri Pirko wrote:
> After this, flow related structures can be used in other code.

LGTM. Definitely makes sense to share flow definition
between OVS and a possible HW switch API.

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> +	/* Ethernet+IPv4 specific members. */
> +	unsigned char       ar_sha[ETH_ALEN];	/* sender hardware address  */
> +	unsigned char       ar_sip[4];		/* sender IP address        */
> +	unsigned char       ar_tha[ETH_ALEN];	/* target hardware address  */
> +	unsigned char       ar_tip[4];		/* target IP address        */
> +} __packed;
>  
> -struct sw_flow_mask {
> +struct ovs_flow_mask {
>  	int ref_count;
>  	struct rcu_head rcu;

Perhaps move rcu_head to the end if you are touching it anyway.

>  	struct list_head list;
> -	struct sw_flow_key_range range;
> -	struct sw_flow_key key;
> +	struct sw_flow_mask mask;
>  };
>  
> -struct sw_flow_match {
> +struct ovs_flow_match {
>  	struct sw_flow_key *key;
>  	struct sw_flow_key_range range;
>  	struct sw_flow_mask *mask;
> @@ -163,36 +106,20 @@ struct sw_flow_stats {
>  	};
>  };
>  
> -struct sw_flow {
> +struct ovs_flow {
>  	struct rcu_head rcu;

Same here.

>  	struct hlist_node hash_node[2];
>  	u32 hash;
>  
> -	struct sw_flow_key key;
> -	struct sw_flow_key unmasked_key;
> -	struct sw_flow_mask *mask;
> +	struct sw_flow flow;
>  	struct sw_flow_actions __rcu *sf_acts;
>  	struct sw_flow_stats stats;
>  };
