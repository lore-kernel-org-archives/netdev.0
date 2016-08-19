From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Fri, 19 Aug 2016 13:20:25 +0200
Message-ID: <57B6EB79.50602@iogearbox.net>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org> <20160819091941.GA2113@salvia> <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: htejun@fb.com, ast@fb.com, davem@davemloft.net, kafai@fb.com,
        fw@strlen.de, harald@redhat.com, netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39180 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754290AbcHSLUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 07:20:38 -0400
In-Reply-To: <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2016 11:19 AM, Pablo Neira Ayuso wrote:
[...]
 > * During the Netfilter Workshop, the main concern to add this new socket

Don't really know what was discussed exactly at NFWS, but ...

 >    ingress hook was that it is too specific. However this new hook in
 >    the network stack looks way more specific more specific since *it only
 >    works for cgroups*.

... why would that be something so overly specific? I don't think that "it
only works for cgroups" would be a narrow use case. While the current
sk_filter() BPF policies are set from application level, it makes sense to
me to have an option for an entity that manages the cgroups to apply an
external policy for networking side as well for participating processes.
It seems like a useful extension to the current sk_filter() infrastructure
iff we carve out the details properly and generic enough, and besides ...

[...]
On 08/19/2016 12:35 PM, Daniel Mack wrote:
[...]
> So - I don't know. The whole 'eBPF in cgroups' idea was born because
> through the discussions over the past months we had on all this, it
> became clear to me that netfilter is not the right place for filtering
> on local tasks. I agree the solution I am proposing in my patch set has
> its downsides, mostly when it comes to transparency to users, but I
> considered that acceptable. After all, we have eBPF users all over the
> place in the kernel already, and seccomp, for instance, isn't any better
> in that regard.

... since you mention seccomp here as well, it would be another good fit
as a program subtype to apply syscall policies for those participants on
a cgroup level too, f.e. to disallow certain syscalls. It would be quite
similar conceptually. So, fwiw, if this is being designed generic enough,
the use cases would go much broader than that.

Cheers,
Daniel
