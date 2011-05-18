From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] bridge: add notification over netlink when STP
 changes state
Date: Wed, 18 May 2011 09:18:48 -0700
Message-ID: <4DD3F168.1060308@candelatech.com>
References: <20110518081718.0b1fc390@nehalam>	<4DD3E38C.30609@candelatech.com> <20110518083948.261ded68@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49809 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932462Ab1ERQTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 12:19:18 -0400
In-Reply-To: <20110518083948.261ded68@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2011 08:39 AM, Stephen Hemminger wrote:
> On Wed, 18 May 2011 08:19:40 -0700
> Ben Greear<greearb@candelatech.com>  wrote:
>
>> On 05/18/2011 08:17 AM, Stephen Hemminger wrote:
>>> The first netlink code in the bridge module was to notify
>>> user space implementations of Spanning Tree Protocol about
>>> new ports. It did not handle the case of kernel mode STP
>>> changing states which could be useful for monitoring.
>>>
>>> This patch causes RTM_NEWLINK message to occur on kernel
>>> transitions. It does not send message if request was from user
>>> space STP, since that would cause reflection and break existing
>>> API.
>>
>> So one app monitoring the system won't get updates if another
>> app makes changes?
>>
>> Ben
>
> For now, yes. Just don't want to break any existing users
> which is more important.

You can get RTM_NEWLINK messages for various reasons..it would
seem a non-buggy program should have no problem dealing with one
more source.

It seems like this code is going to be inconvenient
for anyone wanting to monitor bridges using netlink, and
even if you fix it in the future, there is going to be
backwards compatible hacks that are likely to be quite
ugly!

Thanks,
Ben

>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

