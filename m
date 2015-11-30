From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf, array: fix heap out-of-bounds access when
 updating elements
Date: Mon, 30 Nov 2015 10:29:46 -0800
Message-ID: <20151130182946.GB30762@ast-mbp.thefacebook.com>
References: <674d6a1d4ff0e7728e535dc2d8fe1c5bea1e50b0.1448883657.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@kernel.org, dvyukov@google.com,
	kcc@google.com, glider@google.com, edumazet@google.com,
	sasha.levin@oracle.com, syzkaller@googlegroups.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36669 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392AbbK3S3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 13:29:50 -0500
Received: by pacdm15 with SMTP id dm15so192471135pac.3
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 10:29:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <674d6a1d4ff0e7728e535dc2d8fe1c5bea1e50b0.1448883657.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 01:02:55PM +0100, Daniel Borkmann wrote:
> During own review but also reported by Dmitry's syzkaller [1] it has been
> noticed that we trigger a heap out-of-bounds access on eBPF array maps
> when updating elements. This happens with each map whose map->value_size
> (specified during map creation time) is not multiple of 8 bytes.
...
> In case of array_map_lookup_elem(), the verifier prevents eBPF programs
> from accessing beyond map->value_size through check_map_access(). Also
> from syscall side map_lookup_elem() only copies map->value_size back to
> user, so nothing could leak.
> 
>   [1] http://github.com/google/syzkaller
> 
> Fixes: 28fbcfa08d8e ("bpf: add array type of eBPF maps")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Dmitry, thanks a lot for applying syzkaller to bpf. The issues
got cought much sooner than they would have been discovered otherwise.
Looks like the fuzzing has limited dependency chains described
in sys/sys.txt. Can they be improved into doing something like:
single call to map_create followed by many calls to update to
stress oom ? I did it manually so far without kasan.

Daniel, thanks for the fix. Commit log is all good.
Acked-by: Alexei Starovoitov <ast@kernel.org>
