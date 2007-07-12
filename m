From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [2.6.23 PATCH 14/18] dm: netlink add to core
Date: Thu, 12 Jul 2007 09:07:07 -0600
Message-ID: <m1bqehfyp0.fsf@ebiederm.dsl.xmission.com>
References: <20070711210159.GF24114@agk.fab.redhat.com>
	<20070711143423.36722a41.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alasdair G Kergon <agk@redhat.com>, dm-devel@redhat.com,
	linux-kernel@vger.kernel.org, Mike Anderson <andmike@us.ibm.com>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:57606 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757483AbXGLPNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 11:13:53 -0400
In-Reply-To: <20070711143423.36722a41.akpm@linux-foundation.org> (Andrew
	Morton's message of "Wed, 11 Jul 2007 14:34:23 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed, 11 Jul 2007 22:01:59 +0100
> Alasdair G Kergon <agk@redhat.com> wrote:
>
>> From: Mike Anderson <andmike@us.ibm.com>
>> 
>> This patch adds support for the dm_path_event dm_send_event funtions which
>> create and send netlink attribute events.
>> 
>> ...
>>
>> --- linux.orig/drivers/md/dm-netlink.c 2007-07-11 21:37:50.000000000 +0100
>> +++ linux/drivers/md/dm-netlink.c	2007-07-11 21:37:51.000000000 +0100
>> @@ -40,6 +40,17 @@ struct dm_event_cache {
>>  
>>  static struct dm_event_cache _dme_cache;
>>  
>> +struct dm_event {
>> +        struct dm_event_cache *cdata;
>> +        struct mapped_device *md;
>> +        struct sk_buff *skb;
>> +        struct list_head elist;
>> +};
>> +
>> +static struct sock *_dm_netlink_sock;
>> +static uint32_t _dm_netlink_daemon_pid;
>> +static DEFINE_SPINLOCK(_dm_netlink_pid_lock);
>
> The usage of this lock makes my head spin a bit.  It's a shame it wasn't
> documented.
>
> There's obviously something very significant happening with process IDs in
> here.  A description of the design would be helpful.  Especially for the
> containerisation guys who no doubt will need to tear their hair out over it
> all ;)

Andrew this actually has nothing to do with process IDs.  The pid
referred to here is the netlink port number. It just happens to be called
a pid.

In this case netlink is being used to simply broadcast events.

I may be a little off but looking at the events types defined.
device down, device up.  Defining a completely new interface for this
looks absolutely absurd.


This is device hotplug isn't it?   As such we should be using the
hotplug infrastructure and not reinventing the wheel here.

If it isn't hotplug it looks like something that inotify should
handle.

If that isn't the case I am fairly certain that md already has a
mechanism to handle this, and those two should stay in sync
if at all possible on this kind of thing.

So this appears to be a gratuitous user interface addition.
Why do we need a new user interface for this?

Eric
