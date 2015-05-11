From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Cleanup the kernel sockets.
Date: Mon, 11 May 2015 10:53:08 -0400 (EDT)
Message-ID: <20150511.105308.148715905895080014.davem@davemloft.net>
References: <87sib76kef.fsf@x220.int.ebiederm.org>
	<20150509011339.GA19116@gondor.apana.org.au>
	<87383633pu.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org,
	cwang@twopensource.com, xemul@openvz.org, eric.dumazet@gmail.com,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	herbert@gondor.apana.org.au
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbbEKOxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 10:53:13 -0400
In-Reply-To: <87383633pu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 08 May 2015 21:05:33 -0500

> Right now the situtation for allocating kernel sockets is a mess.
> - sock_create_kern does not take a namespace parameter.
> - kernel sockets must not reference count a network namespace and keep
>   it alive or else we will have a reference counting loop.
> - The way we avoid the reference counting loop with sk_change_net
>   and sk_release_kernel are major hacks.
> 
> This patchset addresses this mess by fixing sock_create_kern to do
> everything necessary to create a kernel socket.  None of the current
> users of kernel sockets need the network namespace reference counted.
> Either kernel sockets are network namespace aware (and using the current
> hacks) or kernel sockets are limited to the initial network namespace
> in which case it does not matter.
> 
> This patchset starts by addressing tun which should be using normal
> userspace sockets like macvtap.
> 
> Then sock_create_kern is fixed to take a network namespace.
> Then the in kernel status of sockets are passed through to sk_alloc.
> Then sk_alloc is fixed to not reference count the network namespace
>      of kernel sockets.
> Then the callers of sock_create_kern are fixed up to stop using hacks.
> Then netlink which uses it's own flavor of sock_create_kern is fixed.
> 
> Finally the hacks that are sk_change_net and sk_release_kernel are removed.
> 
> When it is all done the code is easier to follow, easier to use, easier
> to maintain and shorter by about 70 lines.
> 
> Reported-by: Ying Xue <ying.xue@windriver.com>

Looks good, applied to net-next, thanks Eric.
