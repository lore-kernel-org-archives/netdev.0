From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Wed, 24 Aug 2011 19:16:38 -0700
Message-ID: <m14o16qlq1.fsf@fess.ebiederm.org>
References: <4E558137.5020900@parallels.com>
	<m1k4a2qqew.fsf@fess.ebiederm.org> <4E55A55B.8090608@parallels.com>
	<20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glauber Costa <glommer@parallels.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41511 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902Ab1HYCQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 22:16:46 -0400
In-Reply-To: <20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Thu, 25 Aug 2011 10:49:56 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Wed, 24 Aug 2011 22:28:59 -0300
> Glauber Costa <glommer@parallels.com> wrote:
>
>> On 08/24/2011 09:35 PM, Eric W. Biederman wrote:
>> > Glauber Costa<glommer@parallels.com>  writes:
>> Hi Eric,
>> 
>> Thanks for your attention.
>> 
>> So, this that you propose was my first implementation. I ended up 
>> throwing it away after playing with it for a while.
>> 
>> One of the first problems that arise from that, is that the sysctls are
>> a tunable visible from inside the container. Those limits, however, are 
>> to be set from the outside world. The code is not much better than that 
>> either, and instead of creating new cgroup structures and linking them 
>> to the protocol, we end up doing it for net ns. We end up increasing 
>> structures just the same...

You don't need to add a netns member to sockets.

But I do agree that there are odd permission issues with using the
existing sysctls and making them per namespace.

However almost everything I have seen with memory limits I have found
very strange.  They all seem like a very bad version of disabling memory
over commits.

>> Also, since we're doing resource control, it seems more natural to use 
>> cgroups. Now, the fact that there are no correlation whatsoever between 
>> cgroups and namespaces does bother me. But that's another story, much 
>> more broader and general than this patch.
>> 
>
> I think using cgroup makes sense. A question in mind is whehter it is
> better to integrate this kind of 'memory usage' controls to memcg or
> not.

Maybe.  When sockets start getting a cgroup member I start wondering,
how many cgroup members will sockets potentially belong to.

> How do you think ? IMHO, having cgroup per class of object is messy.
> ...
> How about adding 
> 	memory.tcp_mem 
> to memcg ?
>
> Or, adding kmem cgroup ?
>
>> About overhead, since this is the first RFC, I did not care about 
>> measuring. However, it seems trivial to me to guarantee that at least 
>> that it won't impose a significant performance penalty when it is 
>> compiled out. If we're moving forward with this implementation, I will
>> include data in the next release so we can discuss in this basis.
>> 
>
> IMHO, you should show performance number even if RFC. Then, people will
> see patch with more interests.

And also compiled out doesn't really count.  Cgroups are something you
want people to compile into distributions for the common case, and you
don't want to impose a noticeable performance penalty for the common
case.

Eric
