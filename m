From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/4] openvswitch: refactor ovs flow extract
 API.
Date: Sat, 13 Sep 2014 16:47:08 -0400 (EDT)
Message-ID: <20140913.164708.1690675945507354047.davem@davemloft.net>
References: <1410478084-1436-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbaIMUrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:47:10 -0400
In-Reply-To: <1410478084-1436-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 11 Sep 2014 16:28:04 -0700

> @@ -250,7 +251,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
>  	stats = this_cpu_ptr(dp->stats_percpu);
>  
>  	/* Extract flow from 'skb' into 'key'. */
> -	error = ovs_flow_extract(skb, p->port_no, &key);
> +	error = ovs_flow_key_extract(skb, &key);
>  	if (unlikely(error)) {
>  		kfree_skb(skb);
>  		return;
...
> @@ -611,5 +604,35 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
>  		}
>  	}
>  
> +	OVS_CB(skb)->pkt_key = key;
>  	return 0;

Wow, have you really been putting pointers to kernel stack variables
into the SKB control block all this time?

That's error prone as well as asking for trouble.

Please adjust the code to not do this.
