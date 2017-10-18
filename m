From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Wed, 18 Oct 2017 06:25:26 -0700
Message-ID: <20171018132526.GC1302522@devbig577.frc2.facebook.com>
References: <cover.1508251210.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@kernel.org, john.fastabend@gmail.com,
        mark.rutland@arm.com, richard@nod.at, sp3485@columbia.edu,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dennis Zhou <dennisszhou@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:47264 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753821AbdJRNZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 09:25:31 -0400
Content-Disposition: inline
In-Reply-To: <cover.1508251210.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Daniel.

(cc'ing Dennis)

On Tue, Oct 17, 2017 at 04:55:51PM +0200, Daniel Borkmann wrote:
> The set fixes a splat in devmap percpu allocation when we alloc
> the flush bitmap. Patch 1 is a prerequisite for the fix in patch 2,
> patch 1 is rather small, so if this could be routed via -net, for
> example, with Tejun's Ack that would be good. Patch 3 gets rid of
> remaining PCPU_MIN_UNIT_SIZE checks, which are percpu allocator
> internals and should not be used.
> 
> Thanks!
> 
> Daniel Borkmann (3):
>   mm, percpu: add support for __GFP_NOWARN flag

This looks fine.

>   bpf: fix splat for illegal devmap percpu allocation
>   bpf: do not test for PCPU_MIN_UNIT_SIZE before percpu allocations

These look okay too but if it helps percpu allocator can expose the
maximum size / alignment supported to take out the guessing game too.

Also, the reason why PCPU_MIN_UNIT_SIZE is what it is is because
nobody needed anything bigger.  Increasing the size doesn't really
cost much at least on 64bit archs.  Is that something we want to be
considering?

Thanks.

-- 
tejun
