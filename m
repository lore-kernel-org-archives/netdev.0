From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] core: fix the use of this_cpu_ptr
Date: Thu, 28 Mar 2013 14:38:02 +0000
Message-ID: <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com> <1364475933.15753.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: roy.qing.li@gmail.com, Shan Wei <davidshan@tencent.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a194-81.smtp-out.amazonses.com ([199.255.194.81]:15480 "EHLO
	a194-81.smtp-out.amazonses.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756215Ab3C1Orv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 10:47:51 -0400
In-Reply-To: <1364475933.15753.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Mar 2013, Eric Dumazet wrote:

> > flush_tasklet is not percpu var, and percpu is percpu var, and
> > 	this_cpu_ptr(&info->cache->percpu->flush_tasklet)
> > is not equal to
> > 	&this_cpu_ptr(info->cache->percpu)->flush_tasklet

&this_cpu_ptr is always an error since you are taking the addresss of an
address.

this_cpu_ptr(&structure) is the right way to get the address of the cpu
instance for this cpu for a per cpu structure.

> Christoph, could this kind of error be detected by the compiler or
> sparse ?

The per cpu variables are marked with __percpu. This should be detected by
sparse.
