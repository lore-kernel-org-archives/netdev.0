From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: fix double-fdput in replace_map_fd_with_map_ptr()
Date: Tue, 26 Apr 2016 22:48:07 +0200
Message-ID: <571FD407.4010803@iogearbox.net>
References: <1461702386-17490-1-git-send-email-jannh@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Jann Horn <jannh@google.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59028 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815AbcDZUsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 16:48:10 -0400
In-Reply-To: <1461702386-17490-1-git-send-email-jannh@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2016 10:26 PM, Jann Horn wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks!
