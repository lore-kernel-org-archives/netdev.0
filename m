From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Fri, 19 Aug 2016 18:31:04 +0200
Message-ID: <20160819163104.GA25216@salvia>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
 <57B6EB79.50602@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33362 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753911AbcHSQbN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 12:31:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F1377165ABF
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 18:31:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CF999FF6F4
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 18:31:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4FF35FF2FC
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 18:31:09 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <57B6EB79.50602@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 01:20:25PM +0200, Daniel Borkmann wrote:
> On 08/19/2016 11:19 AM, Pablo Neira Ayuso wrote:
> [...]
> > * During the Netfilter Workshop, the main concern to add this new socket
> 
> Don't really know what was discussed exactly at NFWS, but ...

Slides are available here:

http://workshop.netfilter.org/2016/wiki/index.php/File_Cgroup-matches-NFWS2016.html

We missed you Daniel, I hope you can make it next year ;-)

> >    ingress hook was that it is too specific. However this new hook in
> >    the network stack looks way more specific more specific since *it only
> >    works for cgroups*.
> 
> ... why would that be something so overly specific? I don't think that "it
> only works for cgroups" would be a narrow use case. While the current
> sk_filter() BPF policies are set from application level, it makes sense to
> me to have an option for an entity that manages the cgroups to apply an
> external policy for networking side as well for participating processes.
> It seems like a useful extension to the current sk_filter() infrastructure
> iff we carve out the details properly and generic enough, and besides ...

This forces anyone to filter socket traffic from cgroups, so this
makes the networking infrastructure dependent on cgroups for no
reason, instead of simply using the cgroupv1, cgroupv2, or whatever
other information as yet another selector.

> [...]
> On 08/19/2016 12:35 PM, Daniel Mack wrote:
> [...]
> >So - I don't know. The whole 'eBPF in cgroups' idea was born because
> >through the discussions over the past months we had on all this, it
> >became clear to me that netfilter is not the right place for filtering
> >on local tasks. I agree the solution I am proposing in my patch set has
> >its downsides, mostly when it comes to transparency to users, but I
> >considered that acceptable. After all, we have eBPF users all over the
> >place in the kernel already, and seccomp, for instance, isn't any better
> >in that regard.
> 
> ... since you mention seccomp here as well, it would be another good fit
> as a program subtype to apply syscall policies for those participants on
> a cgroup level too, f.e. to disallow certain syscalls. It would be quite
> similar conceptually. So, fwiw, if this is being designed generic enough,
> the use cases would go much broader than that.

Why do you need global seccomp policies? The process knows better what
he needs to place in his sandbox, so attaching this from the process
itself makes more sense to me... Anyway, this reminds me to selinux.

Back to my main point, I would not expect we have to request sysadmins
to dump BPF bytecode to understand what global policy is being
enforced.
