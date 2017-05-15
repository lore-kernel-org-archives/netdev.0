From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: sr: fix user space compilation error with
 old glibc
Date: Mon, 15 May 2017 10:09:22 -0400 (EDT)
Message-ID: <20170515.100922.2194549018034831667.davem@davemloft.net>
References: <20170515110320.23369-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35170 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932677AbdEOOJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 10:09:25 -0400
In-Reply-To: <20170515110320.23369-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Mon, 15 May 2017 13:03:20 +0200

> When seg6.h is included in a user space program that also includes
> netinet/in.h, it results in multiple definitions of structures such as
> struct in6_addr. Recent glibc versions have a workaround that consists in
> defining __USE_KERNEL_IPV6_DEFS to prevent duplicates. However, such a
> program will fail to compile with older glibc versions.
> 
> This patch ensures that including seg6.h will work in any case.
> 
> v2: do not try to handle __USE_KERNEL_IPV6_DEFS case in seg6.h
> 
> Fixes: ea3ebc73b46fbdb049dafd47543bb22efaa09c8e ("uapi: fix linux/seg6.h and linux/seg6_iptunnel.h userspace compilation errors")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Please, no.

The reason we put together a method by which glibc and the kernel can
stay out of eachother's way in header files is exactly so that we
don't need ifdefs that conditionally do netinet/in.h vs. using the
kernel header.

There are more than a dozen other UAPI headers which make use of
linux/in6.h and none of them jump through hoops like what is being
proposed here, and that's on purpose.

So special casing this one one header is really not the way to go.
