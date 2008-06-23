From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 2/8] bonding: Check return of dev_set_promiscuity/allmulti
Date: Mon, 23 Jun 2008 09:36:06 +0800
Message-ID: <485EFE06.7040104@cn.fujitsu.com>
References: <485AFFD2.4090304@cn.fujitsu.com> <20080619.190724.264140435.davem@davemloft.net> <485D462E.3060003@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org, fubar@us.ibm.com, kaber@trash.net
To: Joe Eykholt <jeykholt@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56762 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbYFWBkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jun 2008 21:40:12 -0400
In-Reply-To: <485D462E.3060003@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Eykholt said the following on 2008-6-22 2:19:
> David Miller wrote:
>> From: Wang Chen <wangchen@cn.fujitsu.com>
>> Date: Fri, 20 Jun 2008 08:54:42 +0800
>>
>>> @@ -419,8 +419,11 @@ static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
>>>  	}
>>>  
>>>  	if (!bond->alb_info.primary_is_promisc) {
>>> -		bond->alb_info.primary_is_promisc = 1;
>>> -		dev_set_promiscuity(bond->curr_active_slave->dev, 1);
>>> +		/* dev_set_promiscuity might overflow, check it here */
>>> +		if (!dev_set_promiscuity(bond->curr_active_slave->dev, 1))
>> Like the first patch, please don't add such comments.
>>
>>> @@ -955,6 +965,9 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
>>>  	}
>>>  
>>>  	if (new_active) {
>>> +		/* FIXME: promiscuity and allmulti might overflow,
>>> +		 * but bond_mc_swap's caller likes quiet handle.
>>> +		 */
>>>  		if (bond->dev->flags & IFF_PROMISC) {
>>>  			dev_set_promiscuity(new_active->dev, 1);
>>>  		}
>> Please reword this comment.  The issue is that this code path has no
>> mechanism to signal errors upstream.  It isn't about a specific type
>> of error condition in particular, it's about error handling capabilites
>> in general.
> 
> If netdev->promiscuity overflows, shouldn't there be a WARN_ON or BUG_ON
> that catches that?  Either someone forgot to clean up, or much less likely,
> the counter needs to be widened.  It isn't necessarily the current caller's
> fault, but some indication of the problem is better than nothing.
> 

If promiscuity overflows, dev_set_promiscuity will printk(KERN_WARNING) now.
Compare to that, WARN_ON has more information about modules info and dump stack.
But I think printk has enough information to indicate the problem and we
don't need WARN_ON.
How do you think?

