From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Mon, 03 Mar 2008 11:52:49 +0300
Message-ID: <47CBBC61.1010605@openvz.org>
References: <47C6D743.1050802@openvz.org>	<m1y794514k.fsf@ebiederm.dsl.xmission.com> <47C7B779.808@openvz.org> <m1ve453lkp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46513 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505AbYCCIx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 03:53:59 -0500
In-Reply-To: <m1ve453lkp.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@openvz.org> writes:
> 
>> I could use the struct net pointer values (obtained with sprintf(id, "%p", net))
>> instead, but exporting internal kernel addresses seemed even uglier.
> 
> Agreed.
> 
>>> Can you try this approach by capturing a struct pid instead of an id
>>> in a new global namespace? 
>> This is a bad approach. When task, that created the namespace dies, his
>> pid is removed from the pidmap and can be reused, so we can get another
>> net with the same id.
> 
> It takes a little updating of how we use pids.  The easiest method
> is to add an extra counter.  So we know when someone besides the hash
> chains is using the pid as an id.  However it might make sense to actually
> have a net namespace pointer in the pid.

No, please, no. I'm strongly opposed to making pids provide identification
for anything we need in the kernel.

>> This net's id is not supposed to be used to address any net in the kernel.
>> And I see no problems with migration - you can change the net's id safely
>> during checkpoint/restart - tasks will always see this one via the /proc/net
>> symlink, which is dynamic.
> 
> So you are really talking about a hidden id.  There are just enough
> ways for something like that to slip out I'm not especially
> comfortable with the idea.
> 
> I really think we need something clean that we can live with, and be
> proud of.  However we implement the enhancement to /proc/net this has
> to be maintained for decades.
> 
> Eric
> 

