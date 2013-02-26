From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] core: Add ioctls to control device unicast hw
 addresses
Date: Tue, 26 Feb 2013 17:15:03 -0500 (EST)
Message-ID: <20130226.171503.1736601811583226926.davem@davemloft.net>
References: <20130226.150309.1215210522427869530.davem@davemloft.net>
	<512D1A01.9020301@redhat.com>
	<512D300F.20405@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3BZWPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 17:15:07 -0500
In-Reply-To: <512D300F.20405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 26 Feb 2013 13:58:39 -0800

> [...]
> 
>>>>
>>>>
>>>> [RFC PATCH] rtnetlink: Add support for adding/removing additional hw
>>>> addresses.
>>>>
>>>> Add an ability to add and remove HW addresses to the device
>>>> unicast and multicast address lists.  Right now, we only have
>>>> an ioctl() to manage the multicast addresses and there is no
>>>> way the manage the unicast list.
>>>>
>>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>>
>>> This is a step in the right direction, and you're right that there is
>>> a difficulty in detecting whether support exists or not.
>>>
>>> I am so surprised that we've have ->set_rx_mode() support for multiple
>>> unicast MAC addresses in so many drivers all this time, yet no way
>>> outside of FDB to make use of it at all.
>>
>> And even that is not always available.  In most drivers it requires
>> module parameters or other explicit configuration steps.  Meanwhile
>> set_rx_mode() doesn't seem to depend on any of those and just does the
>> right thing.
>>
>> For what I was trying to do ioctl() was a really easy way out for both
>> kernel and user space implementation, so I gave is shot.
>>
>> -vlad
>>
> 
> Don't we already support this with

The whole point is that these multiple-unicast-address configuration
facilities are inaccessible without FDB, and there is no reason
whatsoever for that.
