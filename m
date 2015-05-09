From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/6] Cleanup the kernel sockets.
Date: Sat, 9 May 2015 10:38:53 +0800
Message-ID: <20150509023853.GA19695@gondor.apana.org.au>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
 <87wq0kcqlm.fsf@x220.int.ebiederm.org>
 <20150508140733.GA13325@gondor.apana.org.au>
 <87sib76kef.fsf@x220.int.ebiederm.org>
 <20150509011339.GA19116@gondor.apana.org.au>
 <87383633pu.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Ying Xue <ying.xue@windriver.com>,
	netdev@vger.kernel.org, cwang@twopensource.com, xemul@openvz.org,
	eric.dumazet@gmail.com, maxk@qti.qualcomm.com,
	stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:52888 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbbEICjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 22:39:13 -0400
Content-Disposition: inline
In-Reply-To: <87383633pu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 08, 2015 at 09:05:33PM -0500, Eric W. Biederman wrote:
> 
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

Looks good to me.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
