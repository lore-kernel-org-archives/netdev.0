From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH] core: Add ioctls to control device unicast hw addresses
Date: Tue, 26 Feb 2013 15:24:33 -0500
Message-ID: <512D1A01.9020301@redhat.com>
References: <20130226.124322.28904104699526114.davem@davemloft.net> <1361907862-13009-1-git-send-email-vyasevic@redhat.com> <20130226.150309.1215210522427869530.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644Ab3BZUYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 15:24:36 -0500
In-Reply-To: <20130226.150309.1215210522427869530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2013 03:03 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Tue, 26 Feb 2013 14:44:22 -0500
>
>> David Miller wrote:
>>> No new ioctls please, extend the netlink interfaces as necessary
>>> instead.
>>>
>>> Thanks.
>>
>> So, something like below patch (compiled only) would be better in your opinion?
>> The one concern I have is that there is no way to probe for the availabilty
>> of this functionality, since netlink will just ignore unknown types and appear
>> to succeed.  With an ioctl it is clear if the support is present.
>>
>> -- >8 --
>>
>>
>> [RFC PATCH] rtnetlink: Add support for adding/removing additional hw addresses.
>>
>> Add an ability to add and remove HW addresses to the device
>> unicast and multicast address lists.  Right now, we only have
>> an ioctl() to manage the multicast addresses and there is no
>> way the manage the unicast list.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>
> This is a step in the right direction, and you're right that there is
> a difficulty in detecting whether support exists or not.
>
> I am so surprised that we've have ->set_rx_mode() support for multiple
> unicast MAC addresses in so many drivers all this time, yet no way
> outside of FDB to make use of it at all.

And even that is not always available.  In most drivers it requires
module parameters or other explicit configuration steps.  Meanwhile 
set_rx_mode() doesn't seem to depend on any of those and just does the 
right thing.

For what I was trying to do ioctl() was a really easy way out for both 
kernel and user space implementation, so I gave is shot.

-vlad

>
> Anyways, as per the feature detection issue, we could create a new
> RTM_* operation that returns a u32 feature flag mask.  It's just one
> idea.
>
