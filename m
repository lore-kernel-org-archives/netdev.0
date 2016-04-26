From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: fix double-fdput in replace_map_fd_with_map_ptr()
Date: Tue, 26 Apr 2016 13:44:46 -0700
Message-ID: <20160426204444.GA45613@ast-mbp.thefacebook.com>
References: <1461702386-17490-1-git-send-email-jannh@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jann Horn <jannh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35108 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbcDZUou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 16:44:50 -0400
Received: by mail-pa0-f41.google.com with SMTP id iv1so10866337pac.2
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 13:44:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1461702386-17490-1-git-send-email-jannh@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 10:26:26PM +0200, Jann Horn wrote:
> When bpf(BPF_PROG_LOAD, ...) was invoked with a BPF program whose bytecode
> references a non-map file descriptor as a map file descriptor, the error
> handling code called fdput() twice instead of once (in __bpf_map_get() and
> in replace_map_fd_with_map_ptr()). If the file descriptor table of the
> current task is shared, this causes f_count to be decremented too much,
> allowing the struct file to be freed while it is still in use
> (use-after-free). This can be exploited to gain root privileges by an
> unprivileged user.
> 
> This bug was introduced in
> commit 0246e64d9a5f ("bpf: handle pseudo BPF_LD_IMM64 insn"), but is only
> exploitable since
> commit 1be7f75d1668 ("bpf: enable non-root eBPF programs") because
> previously, CAP_SYS_ADMIN was required to reach the vulnerable code.
> 
> (posted publicly according to request by maintainer)
> 
> Signed-off-by: Jann Horn <jannh@google.com>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>
