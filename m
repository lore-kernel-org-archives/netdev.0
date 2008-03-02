From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Sat, 01 Mar 2008 19:29:26 -0700
Message-ID: <m1ve453lkp.fsf@ebiederm.dsl.xmission.com>
References: <47C6D743.1050802@openvz.org>
	<m1y794514k.fsf@ebiederm.dsl.xmission.com> <47C7B779.808@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39106 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbYCBCbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 21:31:10 -0500
In-Reply-To: <47C7B779.808@openvz.org> (Pavel Emelyanov's message of "Fri, 29
	Feb 2008 10:42:49 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> writes:

> I could use the struct net pointer values (obtained with sprintf(id, "%p", net))
> instead, but exporting internal kernel addresses seemed even uglier.

Agreed.

>> Can you try this approach by capturing a struct pid instead of an id
>> in a new global namespace? 
>
> This is a bad approach. When task, that created the namespace dies, his
> pid is removed from the pidmap and can be reused, so we can get another
> net with the same id.

It takes a little updating of how we use pids.  The easiest method
is to add an extra counter.  So we know when someone besides the hash
chains is using the pid as an id.  However it might make sense to actually
have a net namespace pointer in the pid.

>
> This net's id is not supposed to be used to address any net in the kernel.
> And I see no problems with migration - you can change the net's id safely
> during checkpoint/restart - tasks will always see this one via the /proc/net
> symlink, which is dynamic.

So you are really talking about a hidden id.  There are just enough
ways for something like that to slip out I'm not especially
comfortable with the idea.

I really think we need something clean that we can live with, and be
proud of.  However we implement the enhancement to /proc/net this has
to be maintained for decades.

Eric
