From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next,1/3] bonding: fix vlan 0 addition and removal
Date: Tue, 6 Aug 2013 02:37:35 +0200
Message-ID: <20130806003735.GA14443@redhat.com>
References: <1375709304-16778-2-git-send-email-nikolay@redhat.com>
 <20130805215126.GB3859@redhat.com>
 <20130805.160822.47868741818443064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nikolay@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055Ab3HFAid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 20:38:33 -0400
Content-Disposition: inline
In-Reply-To: <20130805.160822.47868741818443064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 04:08:22PM -0700, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Mon, 5 Aug 2013 23:51:26 +0200
>
>> @@ -69,7 +69,6 @@
>>  #include <net/arp.h>
>>  #include <linux/mii.h>
>>  #include <linux/ethtool.h>
>> -#include <linux/if_vlan.h>
>>  #include <linux/if_bonding.h>
>>  #include <linux/jiffies.h>
>>  #include <linux/preempt.h>
>> @@ -1976,7 +1975,7 @@ static int __bond_release_one(struct net_device
>> *bond_dev,
>>  		bond_set_carrier(bond);
>>  		eth_hw_addr_random(bond_dev);
>>  -		if (bond_vlan_used(bond)) {
>> +		if (vlan_uses_dev(bond_dev)) {
>
>If you're adding a use of vlan_uses_dev(), you should retain the
>if_vlan.h include, not remove it.

I've added the usage of vlan_uses_dev_rcu() to bonding.h, so bonding.h
already includes linux/if_vlan.h, and thus any other bonding file doesn't
need it, cause it always includes bonding.h.

Sorry, my bad, should have added it to the commit message.
