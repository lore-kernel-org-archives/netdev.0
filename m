From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 12:34:59 -0600
Message-ID: <m1y7swvo6k.fsf_-_@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<20060816115313.GC31810@sergelap.austin.ibm.com>
	<44FD7CF0.4030009@fr.ibm.com>
	<m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>
	<20060905165328.GA17317@MAIL.13thfloor.at>
	<44FE907F.7090508@fr.ibm.com>
	<20060906165642.GA26202@MAIL.13thfloor.at>
	<44FF0760.1040600@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, Andrey Savochkin <saw@sw.ru>, alexey@sw.ru,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:31666 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1751136AbWIFSfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 14:35:55 -0400
To: Kir Kolyshkin <kir@openvz.org>
In-Reply-To: <44FF0760.1040600@openvz.org> (Kir Kolyshkin's message of "Wed,
	06 Sep 2006 21:37:36 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kir Kolyshkin <kir@openvz.org> writes:

> Herbert Poetzl wrote:
>> my point (until we have an implementation which clearly
>> shows that performance is equal/better to isolation)
>> is simply this:
>>
>>  of course, you can 'simulate' or 'construct' all the
>>  isolation scenarios with kernel bridging and routing
>>  and tricky injection/marking of packets, but, this
>>  usually comes with an overhead ...
>>   
> Well, TANSTAAFL*, and pretty much everything comes with an overhead. 
> Multitasking comes with the (scheduler, context switch, CPU cache, etc.) 
> overhead -- is that the reason to abandon it? OpenVZ and Linux-VServer 
> resource management also adds some overhead -- do we want to throw it away?
>
> The question is not just "equal or better performance", the question is 
> "what do we get and how much we pay for it".

Equal or better performance is certainly required when we have the code
compiled in but aren't using it.  We must not penalize the current code.

> Finally, as I understand both network isolation and network 
> virtualization (both level2 and level3) can happily co-exist. We do have 
> several filesystems in kernel. Let's have several network virtualization 
> approaches, and let a user choose. Is that makes sense?

If there are not compelling arguments for using both ways of doing
it is silly to merge both, as it is more maintenance overhead.

That said I think there is a real chance if we can look at the bind
filtering and find a way to express that in the networking stack
through iptables.  Using the security hooks conflicts with things
like selinux.   Although it would be interesting to see if selinux
can already implement general purpose layer 3 filtering.

The more I look the gut feel I have is that the way to proceed would
be to add a new table that filters binds, and connects.  Plus a new
module that would look at a process creating a socket and tell us if
it is the appropriate group of processes.  With a little care that
would be a general solution to the layer 3 filtering problem.

Eric
