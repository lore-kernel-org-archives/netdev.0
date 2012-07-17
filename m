From: David Miller <davem@davemloft.net>
Subject: Re: That's pretty much it for 3.5.0
Date: Tue, 17 Jul 2012 14:02:41 -0700 (PDT)
Message-ID: <20120717.140241.1599386555723262095.davem@davemloft.net>
References: <5005B881.8010505@intel.com>
	<20120717.122459.2240133900020140698.davem@davemloft.net>
	<5005D008.6060103@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755248Ab2GQVCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 17:02:44 -0400
In-Reply-To: <5005D008.6060103@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 17 Jul 2012 13:50:16 -0700

> On 7/17/2012 12:24 PM, David Miller wrote:
>> From: John Fastabend <john.r.fastabend@intel.com>
>> Date: Tue, 17 Jul 2012 12:09:53 -0700
>>
>>> although we don't have an early_init hook for netprio_cgroup so this
>>> is probably not correct.
>>
>> The dependency is actually on net_dev_init (a subsys_initcall) rather
>> than a pure_initcall.
>>
>> net_dev_init is what registers the netdev_net_ops, which in turn
>> initializes the netdev list in namespaces such as &init_net
>>
> 
> Ah right thanks sorry for the thrash. I guess we need to check if the
> netdev list in the init_net namespace is initialized.

It's a hack, but we could export and then test dev_boot_phase == 0,
and if that test is true then skip the init_net device walk in the
cgroup code.

But I don't like that very much.

The things this code cares about can't even be an issue until
net_dev_init() runs.

There is a comment warning not to do this in linux/init.h, but we
could change the module_init() in netprio_cgroup.c to some level which
runs after subsys_inticall().  When built as a module, linux/init.h
will translate this into module_init() which is basically the behavior
we want.
