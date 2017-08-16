From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix bpf_trace_printk on 32 bit archs
Date: Tue, 15 Aug 2017 17:32:57 -0700 (PDT)
Message-ID: <20170815.173257.21810623154828496.davem@davemloft.net>
References: <dd122e1ec0eadaf3f8fc11107f7a57177dcd8588.1502840567.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: james.hogan@imgtec.com, ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44416 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752718AbdHPAc6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:32:58 -0400
In-Reply-To: <dd122e1ec0eadaf3f8fc11107f7a57177dcd8588.1502840567.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 16 Aug 2017 01:45:33 +0200

> James reported that on MIPS32 bpf_trace_printk() is currently
> broken while MIPS64 works fine:
> 
>   bpf_trace_printk() uses conditional operators to attempt to
>   pass different types to __trace_printk() depending on the
>   format operators. This doesn't work as intended on 32-bit
>   architectures where u32 and long are passed differently to
>   u64, since the result of C conditional operators follows the
>   "usual arithmetic conversions" rules, such that the values
>   passed to __trace_printk() will always be u64 [causing issues
>   later in the va_list handling for vscnprintf()].
> 
>   For example the samples/bpf/tracex5 test printed lines like
>   below on MIPS32, where the fd and buf have come from the u64
>   fd argument, and the size from the buf argument:
> 
>     [...] 1180.941542: 0x00000001: write(fd=1, buf=  (null), size=6258688)
> 
>   Instead of this:
> 
>     [...] 1625.616026: 0x00000001: write(fd=1, buf=009e4000, size=512)
> 
> One way to get it working is to expand various combinations
> of argument types into 8 different combinations for 32 bit
> and 64 bit kernels. Fix tested by James on MIPS32 and MIPS64
> as well that it resolves the issue.
> 
> Fixes: 9c959c863f82 ("tracing: Allow BPF programs to call bpf_trace_printk()")
> Reported-by: James Hogan <james.hogan@imgtec.com>
> Tested-by: James Hogan <james.hogan@imgtec.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
