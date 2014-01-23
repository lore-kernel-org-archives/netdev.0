From: chenweilong <chenweilong@huawei.com>
Subject: Re: [PATCH] bonding: Don't allow bond devices to change network namespaces.
Date: Thu, 23 Jan 2014 10:41:44 +0800
Message-ID: <52E08168.1000906@huawei.com>
References: <1390382190-1604-1-git-send-email-chenweilong@huawei.com> <20140122094106.GB2814@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:21667 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaAWCmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 21:42:14 -0500
In-Reply-To: <20140122094106.GB2814@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/22 17:41, Jiri Pirko wrote:
> Wed, Jan 22, 2014 at 10:16:30AM CET, chenweilong@huawei.com wrote:
>> From: Weilong Chen <chenweilong@huawei.com>
>>
>> Like bridge, bonding as netdevice doesn't cross netns boundaries.
>>
>> Bonding ports and bonding itself live in same netns.
> 
> I think should should be done for team as well. Openvs already
> has this. I believe that for vlans it is ok to change ns, right?
> 

OK, I'll write a new patch for 'team'.

For vlan dev, I think it's more complex.
1.Move vlan dev to a new ns, its real dev is in old ns, vlan
  can not work.
2.Move vlan real dev to a new ns, vlan dev is in old ns, vlan
  can not work.
If someone want to move vlan and its real dev to new ns, he must
do 1) and 2) or 2) and 1), both way are breaking the vlan down. I
think move real dev to new ns, and add a new vlan dev will be better.

Maybe I need write another patch for 'vlan'.

>>
>> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 3 +++
>> 1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index f00dd45..897d153 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3916,6 +3916,9 @@ void bond_setup(struct net_device *bond_dev)
>> 	 * capable
>> 	 */
>>
>> +	/* Don't allow bond devices to change network namespaces. */
>> +	bond_dev->features |= NETIF_F_NETNS_LOCAL;
>> +
>> 	bond_dev->hw_features = BOND_VLAN_FEATURES |
>> 				NETIF_F_HW_VLAN_CTAG_TX |
>> 				NETIF_F_HW_VLAN_CTAG_RX |
>> -- 
>> 1.7.12
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
