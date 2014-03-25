From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 3/3] bonding: add ratelimit for bond_arp_rcv()
Date: Tue, 25 Mar 2014 16:17:41 +0800
Message-ID: <53313BA5.10008@huawei.com>
References: <1395731037-4812-1-git-send-email-dingtianhong@huawei.com> <1395731037-4812-4-git-send-email-dingtianhong@huawei.com> <20140325073455.GB1476@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <andy@greyhouse.net>, <joe@perches.com>,
	<kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:37289 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbaCYIfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 04:35:22 -0400
In-Reply-To: <20140325073455.GB1476@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/25 15:34, Veaceslav Falico wrote:
> On Tue, Mar 25, 2014 at 03:03:57PM +0800, Ding Tianhong wrote:
>> Add ratelimit to avoid spam when processing the arp package.
> 
> You've ratelimited here only debug statements. As with the another
> patchset, I think that it's a bad idea for debugging - if the user turns
> debugging on he wants to see all messages, and otherwise he won't ever see
> any.
> 

more clear, thanks.

Ding

>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 19 +++++++++++--------
>> 1 file changed, 11 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 9e8b888..7328a3f 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2239,13 +2239,15 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
>>     int i;
>>
>>     if (!sip || !bond_has_this_ip(bond, tip)) {
>> -        pr_debug("bva: sip %pI4 tip %pI4 not found\n", &sip, &tip);
>> +        pr_debug_ratelimited("bva: sip %pI4 tip %pI4 not found\n",
>> +                     &sip, &tip);
>>         return;
>>     }
>>
>>     i = bond_get_targets_ip(bond->params.arp_targets, sip);
>>     if (i == -1) {
>> -        pr_debug("bva: sip %pI4 not found in targets\n", &sip);
>> +        pr_debug_ratelimited("bva: sip %pI4 not found in targets\n",
>> +                     &sip);
>>         return;
>>     }
>>     slave->last_rx = jiffies;
>> @@ -2272,8 +2274,8 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>>
>>     alen = arp_hdr_len(bond->dev);
>>
>> -    pr_debug("bond_arp_rcv: bond %s skb->dev %s\n",
>> -         bond->dev->name, skb->dev->name);
>> +    pr_debug_ratelimited("bond_arp_rcv: bond %s skb->dev %s\n",
>> +                 bond->dev->name, skb->dev->name);
>>
>>     if (alen > skb_headlen(skb)) {
>>         arp = kmalloc(alen, GFP_ATOMIC);
>> @@ -2297,10 +2299,11 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>>     arp_ptr += 4 + bond->dev->addr_len;
>>     memcpy(&tip, arp_ptr, 4);
>>
>> -    pr_debug("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
>> -         bond->dev->name, slave->dev->name, bond_slave_state(slave),
>> -         bond->params.arp_validate, slave_do_arp_validate(bond, slave),
>> -         &sip, &tip);
>> +    pr_debug_ratelimited("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
>> +                 bond->dev->name, slave->dev->name,
>> +                 bond_slave_state(slave),
>> +                 bond->params.arp_validate,
>> +                 slave_do_arp_validate(bond, slave), &sip, &tip);
>>
>>     curr_active_slave = rcu_dereference(bond->curr_active_slave);
>>
>> -- 
>> 1.8.0
>>
>>
> 
> .
> 
