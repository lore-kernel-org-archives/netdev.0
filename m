From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ebpf, x86: fix general protection fault when tail
 call is invoked
Date: Wed, 29 Jul 2015 17:04:53 -0700 (PDT)
Message-ID: <20150729.170453.375462793871538401.davem@davemloft.net>
References: <23a2630be3c3d41932b9df134f06b9b44671b55e.1438088105.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010AbbG3AEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 20:04:54 -0400
In-Reply-To: <23a2630be3c3d41932b9df134f06b9b44671b55e.1438088105.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 28 Jul 2015 15:26:36 +0200

> With eBPF JIT compiler enabled on x86_64, I was able to reliably trigger
> the following general protection fault out of an eBPF program with a simple
> tail call, f.e. tracex5 (or a stripped down version of it):
 ...
> Changing the emitter to always use the 4 byte displacement in the lea
> instruction fixes the panic on my side. It increases the tail call instruction
> emission by 3 more byte, but it should cover us from various combinations
> (and perhaps other future increases on related structures).
> 
> After patch, disassembly:
> 
>   [...]
>   9e:   lea    0x80(%rsi,%rdx,8),%rax   <--- CONFIG_LOCKDEP/CONFIG_LOCK_STAT
>         48 8d 84 d6 80 00 00 00
>   a6:   mov    (%rax),%rax
>         48 8b 00
>   [...]
> 
>   [...]
>   9e:   lea    0x50(%rsi,%rdx,8),%rax   <--- No CONFIG_LOCKDEP
>         48 8d 84 d6 50 00 00 00
>   a6:   mov    (%rax),%rax
>         48 8b 00
>   [...]
> 
> Fixes: b52f00e6a715 ("x86: bpf_jit: implement bpf_tail_call() helper")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
