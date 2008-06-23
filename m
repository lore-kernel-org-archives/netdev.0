From: Joe Eykholt <jre@nuovasystems.com>
Subject: Re: [PATCH net-next 2/8] bonding: Check return of dev_set_promiscuity/allmulti
Date: Sun, 22 Jun 2008 20:55:05 -0700
Message-ID: <485F1E99.3020406@nuovasystems.com>
References: <485AFFD2.4090304@cn.fujitsu.com> <20080619.190724.264140435.davem@davemloft.net> <485D462E.3060003@cisco.com> <485EFE06.7040104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Eykholt <jeykholt@cisco.com>,
	David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org, fubar@us.ibm.com, kaber@trash.net
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:26765 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbYFWEKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 00:10:18 -0400
In-Reply-To: <485EFE06.7040104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Joe Eykholt said the following on 2008-6-22 2:19:
>> David Miller wrote:
>>> From: Wang Chen <wangchen@cn.fujitsu.com>
>>> Date: Fri, 20 Jun 2008 08:54:42 +0800
>>>
>>>> @@ -419,8 +419,11 @@ static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
>>>>  	}
>>>>  
>>>>  	if (!bond->alb_info.primary_is_promisc) {
>>>> -		bond->alb_info.primary_is_promisc = 1;
>>>> -		dev_set_promiscuity(bond->curr_active_slave->dev, 1);
>>>> +		/* dev_set_promiscuity might overflow, check it here */
>>>> +		if (!dev_set_promiscuity(bond->curr_active_slave->dev, 1))
>>> Like the first patch, please don't add such comments.
>>>
>>>> @@ -955,6 +965,9 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
>>>>  	}
>>>>  
>>>>  	if (new_active) {
>>>> +		/* FIXME: promiscuity and allmulti might overflow,
>>>> +		 * but bond_mc_swap's caller likes quiet handle.
>>>> +		 */
>>>>  		if (bond->dev->flags & IFF_PROMISC) {
>>>>  			dev_set_promiscuity(new_active->dev, 1);
>>>>  		}
>>> Please reword this comment.  The issue is that this code path has no
>>> mechanism to signal errors upstream.  It isn't about a specific type
>>> of error condition in particular, it's about error handling capabilites
>>> in general.
>> If netdev->promiscuity overflows, shouldn't there be a WARN_ON or BUG_ON
>> that catches that?  Either someone forgot to clean up, or much less likely,
>> the counter needs to be widened.  It isn't necessarily the current caller's
>> fault, but some indication of the problem is better than nothing.
>>
> 
> If promiscuity overflows, dev_set_promiscuity will printk(KERN_WARNING) now.
> Compare to that, WARN_ON has more information about modules info and dump stack.
> But I think printk has enough information to indicate the problem and we
> don't need WARN_ON.
> How do you think?

I agree, printk is enough.  If it is reproducible, the cause can be 
determined.  I didn't check to see there was a printk there.

	Thanks,
	Joe

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

