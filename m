From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/33] netns ct: per-netns expectations
Date: Tue, 09 Sep 2008 09:10:34 +0200
Message-ID: <48C6216A.6070103@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-5-git-send-email-adobriyan@gmail.com> <48C60E6E.5080905@trash.net> <20080909070726.GD5786@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64113 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754893AbYIIHKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 03:10:40 -0400
In-Reply-To: <20080909070726.GD5786@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> On Tue, Sep 09, 2008 at 07:49:34AM +0200, Patrick McHardy wrote:
>>> @@ -406,7 +404,7 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
>>>  		}
>>>  	}
>>>  -	if (nf_ct_expect_count >= nf_ct_expect_max) {
>>> +	if (net->ct.expect_count >= nf_ct_expect_max) {
>>>  		if (net_ratelimit())
>>>  			printk(KERN_WARNING
>>>  			       "nf_conntrack: expectation table full\n");
>> I assume these message are globally visible even with namespaces?
>> Can we make this (and the corresponding ct hash message) refer to
>> the namespace? Otherwise it might be a bit confusing.
> 
> This is somewhat peculiar situation.
> 
> netns doesn't have unique ID like, say, ifindex.
> 
> The only number related to netns is "struct net *". They can be
> distinguised by pointer value, but userspace when does clone(CLONE_NEWNET)
> do not, obviously, control it and after creation doesn't have a way to find
> it out.
> 
> And if we print with "%p, net" kernelspace pointer get exposed which is
> not nice.

No, that also wouldn't solve the confusion. I guess conntrack is not
the only subsystem which prints netns related messages, so how about
adding an unique identifier that can be associated by userspace?
