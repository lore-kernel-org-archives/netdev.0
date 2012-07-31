From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Tue, 31 Jul 2012 17:30:17 +0400
Message-ID: <5017DDE9.4020008@parallels.com>
References: <50160EEF.6050406@parallels.com> <87pq7dh6b2.fsf@xmission.com> <87fw89h5zk.fsf@xmission.com> <50179F66.1000604@parallels.com> <878ve0dtw3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23240 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101Ab2GaNa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 09:30:26 -0400
In-Reply-To: <878ve0dtw3.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> First, let's imagine that on host A the loopback device got registered as
>> first device, but on host B for some reason some other device got registered
>> first. In that case after migration from A to B the lo on B will have index
>> equals 2. And there's no any strict requirement that lo's per net operations
>> are registered first. Please, correct me if I'm wrong.
> 
> Actually there is a hard requirement that the loopback device be the
> last device in a network namespace to be unregistered.  We meet that
> requirement by registering the loopback device first
> "net/core/dev.c:net_dev_init()".

Hm... Indeed, and this is good news!

>> Next. In fact, lo is not the only problem. Look at the e.g. sit versus ipgre
>> fallback devices. Both gets created on netns creation and obtain whatever
>> ifindices are generated for them. Even if we make ifidex per netns chances
>> that sit gets registered _strictly_ before ipgre equal zero, since they are
>> both modules.
> 
> True.  However those fallback devices should no longer be needed,
> and even if they are I think you can delete and recreate them.

Good idea! I will look at that direction.

> Making lo the particularly interesting case.

Yup, provided we can manually recreate those auto-created devices this solves
the issue.

>> Just an idea -- is it worth moving the possibility to have ifindidces intersect
>> under CONFIG_<SOMETHING> (EXPERT/CHECKPOINT_RESTORE) to let wider audience check
>> the code in real-life?
> 
> I think the best testing we are going to get diversity wise is to create
> a per netns counter into dev_new_index when net-next opens up.
> 
> Having an ifindex that we can only set at netdevice creation time seems
> reasonable.  

OK, thank you, Eric.

> Eric
> .
> 

Thanks,
Pavel
