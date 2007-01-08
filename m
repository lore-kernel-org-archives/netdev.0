From: Ben Greear <greearb@candelatech.com>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Mon, 08 Jan 2007 08:57:10 -0800
Message-ID: <45A277E6.6000904@candelatech.com>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <459EB627.5040606@candelatech.com> <20070108065346.GA1665@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	dlstevens@us.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:37297 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750913AbXAHQzz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 11:55:55 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070108065346.GA1665@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Fri, Jan 05, 2007 at 12:33:43PM -0800, Ben Greear wrote:
> ...
>   
>> So, I do believe this was the problem we were hitting, and it seems fixed.
>>     
>
> Congratulations!
>
> But I can see one strange thing in vlan.c:
>
> /* Must be invoked with RCU read lock (no preempt) */
> static struct vlan_group *__vlan_find_group(int real_dev_ifindex)
> ...
>  * Must be invoked with RCU read lock (no preempt)
>  */
> struct net_device *__find_vlan_dev(struct net_device *real_dev,
> ...
>
> But later in this file no sign of disabling preemption
> for these calls and for hlist_add_head_rcu and hlist_del_rcu.
>
> I can't imagine how this works?
>   
Perhaps...I didn't RCU-ify VLANs, but I can take a look.

For the record, the soft lockup was using MAC-VLANs, not 802.1Q VLANs, 
so it wouldn't
have been affected by bugs in VLANs one way or the other.

Ben

> Jarek P. 
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


