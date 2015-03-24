From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Tue, 24 Mar 2015 18:06:28 +0100
Message-ID: <20150324180628.278017fb@griffin>
References: <2ca7312e5e3df10ce129315f89c3ab5d82d4d428.1427145009.git.jbenc@redhat.com>
	<20150324.130037.1897087027068811494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, dcbw@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933070AbbCXRGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 13:06:34 -0400
In-Reply-To: <20150324.130037.1897087027068811494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Mar 2015 13:00:37 -0400 (EDT), David Miller wrote:
> From: Jiri Benc <jbenc@redhat.com>
> Date: Mon, 23 Mar 2015 22:10:19 +0100
> 
> > @@ -504,7 +504,8 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
> >  
> >  	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
> >  		list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
> > -			ipvlan_ht_addr_del(addr, !dev->dismantle);
> > +			if (netif_running(dev))
> > +				ipvlan_ht_addr_del(addr, !dev->dismantle);
> >  			list_del_rcu(&addr->anode);
> >  		}
> >  	}
> 
> This is so error prone, because you are depending upon so many implementation
> details to infer a boolean state "is this address hashed".
> 
> So just add the boolean state to struct ipvl_addr, and manage it in
> the ipvlan_ht_addr_{add,del}() code.

I had that originally but then decided to go with smaller memory
footprint. Which obviously doesn't matter much here. I'll send v2 with
the boolean state.

 Jiri

-- 
Jiri Benc
