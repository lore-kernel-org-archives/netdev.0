From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Thu, 11 May 2017 21:29:40 -0400 (EDT)
Message-ID: <20170511.212940.1950696136811799858.davem@davemloft.net>
References: <5d1d290b-7ff7-7f9d-15a0-599596e0778c@fb.com>
        <20170511.150246.650724054596949813.davem@davemloft.net>
        <9afe8b73-806c-1511-dd26-f09e67b85107@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56642 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdELB3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 21:29:43 -0400
In-Reply-To: <9afe8b73-806c-1511-dd26-f09e67b85107@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 11 May 2017 15:58:33 -0700

> Can we than move gnu/stubs.h into include/uapi as well and remove
> the first -I. ?
> Or keep them separate, since this linux/types.h is bpf's arch types.h
> whereas gnu/stubs.h is a hack for glibc /usr/include/features.h ?
> I'm fine whichever way including keeping this patch as-is.

Let's keep it like this for now, and perhaps in the long term we
can have a better more organized piece of infrastructure for this.

So I'll commit this fix for now and happily sparc now works out of the
box for all the selftests and samples as far as I can tell. :-)

This whole thing go me thinking however.  What do you expect to happen
on 32-bit architectures implementing an eBPF JIT?  That's going to
create some serious conflicts and consternation wrt.  tracing which is
going to want to use headers which are for sizeof(void *)==4 whereas
for eBPF natively it's 8.
