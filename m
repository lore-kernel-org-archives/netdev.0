From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v4] netpoll: fix a rtnl lock assertion failure
Date: Wed, 16 Jan 2013 22:54:13 -0500 (EST)
Message-ID: <20130116.225413.1184047803896995845.davem@davemloft.net>
References: <1358242446-4273-1-git-send-email-amwang@redhat.com>
	<1358385885.32167.21.camel@edumazet-glaptop>
	<1358393418.3855.3.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758577Ab3AQDyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:54:14 -0500
In-Reply-To: <1358393418.3855.3.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 17 Jan 2013 11:30:18 +0800

> On Wed, 2013-01-16 at 17:24 -0800, Eric Dumazet wrote:
>> On Tue, 2013-01-15 at 17:34 +0800, Cong Wang wrote:
>> >  	if (np->dev_name)
>> > -		ndev = dev_get_by_name(&init_net, np->dev_name);
>> > +		ndev = __dev_get_by_name(&init_net, np->dev_name);
>> 
>> This change brings interesting bugs.
> 
> Hmm, I didn't realize __dev_get_by_name() doesn't hold the device, so
> just call dev_hold() after this?

Why not just... call dev_get_by_name()?  It doesn't hurt to over-RCU
lock.
