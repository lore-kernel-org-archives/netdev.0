From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Tue, 24 Mar 2015 13:00:37 -0400 (EDT)
Message-ID: <20150324.130037.1897087027068811494.davem@davemloft.net>
References: <2ca7312e5e3df10ce129315f89c3ab5d82d4d428.1427145009.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, dcbw@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510AbbCXRAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:00:40 -0400
In-Reply-To: <2ca7312e5e3df10ce129315f89c3ab5d82d4d428.1427145009.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Mon, 23 Mar 2015 22:10:19 +0100

> @@ -504,7 +504,8 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
>  
>  	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
>  		list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
> -			ipvlan_ht_addr_del(addr, !dev->dismantle);
> +			if (netif_running(dev))
> +				ipvlan_ht_addr_del(addr, !dev->dismantle);
>  			list_del_rcu(&addr->anode);
>  		}
>  	}

This is so error prone, because you are depending upon so many implementation
details to infer a boolean state "is this address hashed".

So just add the boolean state to struct ipvl_addr, and manage it in
the ipvlan_ht_addr_{add,del}() code.
