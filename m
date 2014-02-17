From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] csum_partial_copy_from_user: clean up inconsistencies
 in implementations
Date: Mon, 17 Feb 2014 17:20:56 -0500 (EST)
Message-ID: <alpine.LRH.2.02.1402171714030.21254@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1402151044010.25662@file01.intranet.prod.int.rdu2.redhat.com> <20140217.162105.899153264722449005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mcree@orcon.net.nz, mattst88@gmail.com,
	mathieu.desnoyers@efficios.com, jay.estabrook@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140217.162105.899153264722449005.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 17 Feb 2014, David Miller wrote:

> From: Mikulas Patocka <mpatocka@redhat.com>
> Date: Sat, 15 Feb 2014 10:49:54 -0500 (EST)
> 
> > Here I'm sending a patch for networking to clean up inconsistent 
> > implementations of csum_partial_copy_from_user in various architectures. 
> > This patch doesn't fix any bug, but the confusion in implementations 
> > caused a bug in the past. The patch should be queued for the kernel 3.15.
> > 
> > Mikulas
> 
> Please do not add commentary to the main body text of a patch submission,
> otherwise I have to edit it out.
> 
> The proper way to add commentary is to put it after the "---" delimiter
> at the end of the commit message and before the actual patch.

Interesting - I used "---" as a delimiter between the commentary and the 
git message in the past and some people said that their patch parser can't 
detect "---" and that I should use "From:" line as a delimiter. And now I 
see that your patch parser doesn't detect "From:" and needs "---".

> > From: Mikulas Patocka <mpatocka@redhat.com>
> > 
> > csum_partial_copy_from_user is called only from csum_and_copy_from_user in
> > include/net/checksum.h. csum_and_copy_from_user verifies the userspace
> > range with access_ok, so there is no need to repeat access_ok in the
> > implementation of csum_partial_copy_from_user.

...

> > The purpose of this patch is to make all the implementations of
> > csum_partial_copy_from_user consistent, so that people will keep them
> > consistent in the future.
> > 
> > Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> 
> That is mainly a cleanup and entirely independent of fixing the Alpha
> bug.
> 
> You should submit the Alpha bug fix through the usual arch channels
> and get that into Linus's tree.
> 
> Then, after that fix propagates, you can do the access_ok() global
> cleanup as a separate patch targetting net-next.
> 
> Thanks.

I already pushed the alpha bug fix to the upstream kernel and affected 
stable kernels.

This patch is a cleanup that removes code bloat, intended for the next 
kernel cycle.

Mikulas
