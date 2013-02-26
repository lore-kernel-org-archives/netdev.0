From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] core: Add ioctls to control device unicast hw addresses
Date: Tue, 26 Feb 2013 13:58:39 -0800
Message-ID: <512D300F.20405@intel.com>
References: <20130226.124322.28904104699526114.davem@davemloft.net> <1361907862-13009-1-git-send-email-vyasevic@redhat.com> <20130226.150309.1215210522427869530.davem@davemloft.net> <512D1A01.9020301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26346 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757028Ab3BZV6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 16:58:40 -0500
In-Reply-To: <512D1A01.9020301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>>
>>>
>>> [RFC PATCH] rtnetlink: Add support for adding/removing additional hw
>>> addresses.
>>>
>>> Add an ability to add and remove HW addresses to the device
>>> unicast and multicast address lists.  Right now, we only have
>>> an ioctl() to manage the multicast addresses and there is no
>>> way the manage the unicast list.
>>>
>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>
>> This is a step in the right direction, and you're right that there is
>> a difficulty in detecting whether support exists or not.
>>
>> I am so surprised that we've have ->set_rx_mode() support for multiple
>> unicast MAC addresses in so many drivers all this time, yet no way
>> outside of FDB to make use of it at all.
>
> And even that is not always available.  In most drivers it requires
> module parameters or other explicit configuration steps.  Meanwhile
> set_rx_mode() doesn't seem to depend on any of those and just does the
> right thing.
>
> For what I was trying to do ioctl() was a really easy way out for both
> kernel and user space implementation, so I gave is shot.
>
> -vlad
>

Don't we already support this with


         int                     (*ndo_fdb_add)(struct ndmsg *ndm,
                                                 struct nlattr *tb[],
                                                 struct net_device *dev,
                                                 const unsigned char *addr,
                                                 u16 flags);
          int                     (*ndo_fdb_del)(struct ndmsg *ndm,
                                                 struct nlattr *tb[],
                                                 struct net_device *dev,
                                                 const unsigned char *addr);
          int                     (*ndo_fdb_dump)(struct sk_buff *skb,
                                                  struct 
netlink_callback *cb,
                                                  struct net_device *dev,
                                                  int idx);
