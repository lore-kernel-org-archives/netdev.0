From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Mon, 30 Jul 2012 05:33:05 -0700
Message-ID: <87k3xlfmym.fsf@xmission.com>
References: <50160EEF.6050406@parallels.com> <87pq7dh6b2.fsf@xmission.com>
	<1343649062.21269.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45261 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab2G3MdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 08:33:14 -0400
In-Reply-To: <1343649062.21269.23.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Mon, 30 Jul 2012 13:51:02 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Mon, 2012-07-30 at 03:49 -0700, Eric W. Biederman wrote:
>> Pavel Emelyanov <xemul@parallels.com> writes:
>> 
>> > Currently the RTM_NEWLINK results in -EOPNOTSUPP if the ifinfomsg->ifi_index
>> > is not zero. I propose to allow requesting ifindices on link creation. This
>> > is required by the checkpoint-restore to correctly restore a net namespace
>> > (i.e. -- a container). The question what to do with pre-created devices such
>> > as lo or sit fbdev is open, but for manually created devices this can be 
>> > solved by this patch.
>> 
>> Have you walked through and found the locations where we still rely on
>> ifindex being globally unique?
>> 
>> Last time I was working in this area there were serveral places where
>> things were indexed by just the interface index.
>
> Really ? This would be very strange.

There at least were places that used oif or iff without being pernet
last time I was working on this.

It was never code that I understood particularly well so my memory of
what that code is, is unfortunately fuzzy.

> AFAIK dev_new_index() is always called, even in the
> dev_change_net_namespace() case if there is a conflict.

Except we never have a conflict because it takes an absurd number of
network devices to cause a 32bit counter to wrap.

> And dev_new_index() could use a pernet net->ifindex instead of a
> shared/static one.

Yes.  I made all of the core changes, and held back on making
dev_new_index() use a pernet net->ifindex because of a couple of problem
cases.

It has been a long time and those cases might have been fixed.

I'm not seeing anything obvious in the network stack with a quick skim,
but before we start relying on the property that interface indicies are
not globally unique I expect an good hard look at the networking stack
to see if any of those cases where there were problems still exist.

Eric
