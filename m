From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH V2 01/12] bridge: Add vlan filtering infrastructure
Date: Tue, 18 Dec 2012 16:26:30 -0500
Message-ID: <50D0DF86.9070801@redhat.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>  <1355857263-31197-2-git-send-email-vyasevic@redhat.com> <1355865231.9380.119.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319Ab2LRV0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 16:26:36 -0500
In-Reply-To: <1355865231.9380.119.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2012 04:13 PM, Eric Dumazet wrote:
> On Tue, 2012-12-18 at 14:00 -0500, Vlad Yasevich wrote:
>
>> +static void br_vlan_destroy(struct net_bridge_vlan *vlan)
>> +{
>> +	if (!bitmap_empty(vlan->port_bitmap, PORT_BITMAP_LEN)) {
>> +		pr_err("Attempt to delete a VLAN %d from the bridge with "
>> +		       "non-empty port bitmap (%p)\n", vlan->vid, vlan);
>> +		BUG();
>> +	}
>> +
>> +	hlist_del_rcu(&vlan->hlist);
>> +	synchronize_net();
>> +	kfree_rcu(vlan, rcu);
>> +}
>
> Not clear why you both use synchronize_net() and kfree_rcu()
>


I think this was a left-over from old code.  I think this was
originally here to mimic del_nbp behavior, but I don't think
it's really needed as kfree_rcu should wait until all current
rcu section have completed.

-vlad
