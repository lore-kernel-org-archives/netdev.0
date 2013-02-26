From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] core: Add ioctls to control device unicast hw
 addresses
Date: Tue, 26 Feb 2013 15:03:09 -0500 (EST)
Message-ID: <20130226.150309.1215210522427869530.davem@davemloft.net>
References: <20130226.124322.28904104699526114.davem@davemloft.net>
	<1361907862-13009-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035Ab3BZUDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 15:03:13 -0500
In-Reply-To: <1361907862-13009-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 26 Feb 2013 14:44:22 -0500

> David Miller wrote:
>> No new ioctls please, extend the netlink interfaces as necessary
>> instead.
>>
>> Thanks.
> 
> So, something like below patch (compiled only) would be better in your opinion?
> The one concern I have is that there is no way to probe for the availabilty
> of this functionality, since netlink will just ignore unknown types and appear
> to succeed.  With an ioctl it is clear if the support is present.
> 
> -- >8 --
> 
> 
> [RFC PATCH] rtnetlink: Add support for adding/removing additional hw addresses.
> 
> Add an ability to add and remove HW addresses to the device
> unicast and multicast address lists.  Right now, we only have
> an ioctl() to manage the multicast addresses and there is no
> way the manage the unicast list.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

This is a step in the right direction, and you're right that there is
a difficulty in detecting whether support exists or not.

I am so surprised that we've have ->set_rx_mode() support for multiple
unicast MAC addresses in so many drivers all this time, yet no way
outside of FDB to make use of it at all.

Anyways, as per the feature detection issue, we could create a new
RTM_* operation that returns a u32 feature flag mask.  It's just one
idea.
