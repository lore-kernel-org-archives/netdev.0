From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: reset bridge mtu after deleting an interface
Date: Sat, 14 Mar 2015 19:12:56 -0400 (EDT)
Message-ID: <20150314.191256.1947233794659640457.davem@davemloft.net>
References: <20150313140822.GA30448@oracle.com>
	<55039924.3050609@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbbCNXM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 19:12:57 -0400
In-Reply-To: <55039924.3050609@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Fri, 13 Mar 2015 19:12:52 -0700

> On 3/13/15, 7:08 AM, Venkat Venkatsubra wrote:
>> On adding an interface br_add_if() sets the MTU to the min of
>> all the interfaces. Do the same thing on removing an interface too
>> in br_del_if.
>>
>> Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
>> ---
>>   net/bridge/br_if.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index b087d27..1849d96 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -563,6 +563,8 @@ int br_del_if(struct net_bridge *br, struct
>> net_device *dev)
>>   	 */
>>   	del_nbp(p);
>>   +	dev_set_mtu(br->dev, br_min_mtu(br));
>> +
>>   	spin_lock_bh(&br->lock);
>>   	changed_addr = br_stp_recalculate_bridge_id(br);
>>   	spin_unlock_bh(&br->lock);
> This looks good to me.
> 
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks everyone.
