From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 2/3] bonding: ratelimit pr_err() for bond xmit
 broadcast
Date: Tue, 25 Mar 2014 16:12:43 +0800
Message-ID: <53313A7B.7040802@huawei.com>
References: <1395731037-4812-1-git-send-email-dingtianhong@huawei.com>	 <1395731037-4812-3-git-send-email-dingtianhong@huawei.com> <1395731963.3010.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:49309 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbaCYITP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 04:19:15 -0400
In-Reply-To: <1395731963.3010.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/25 15:19, Joe Perches wrote:
> On Tue, 2014-03-25 at 15:03 +0800, Ding Tianhong wrote:
>> It may spam if the system is out of the memory, add ratelimit for it.
> 
> Sorry, I didn't follow whatever discussion occurred here.
> 
> I thought you were going to use net_err_ratelimited
> for these?
> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> []
>> @@ -3656,8 +3656,8 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
>> -				pr_err("%s: Error: bond_xmit_broadcast(): skb_clone() failed\n",
>> -				       bond_dev->name);
>> +				pr_err_ratelimited("%s: Error: bond_xmit_broadcast(): skb_clone() failed\n",
>> +						   bond_dev->name);
> 
> also btw, it's better I think to use
> %s, __func__ instead of embedding
> explicit function names
> 
> 
> 
Yes, maybe I still didn't clear when to use net_err_ratelimited, thanks.

Ding
