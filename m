From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: fix double-fdput in replace_map_fd_with_map_ptr()
Date: Tue, 26 Apr 2016 17:38:03 -0400 (EDT)
Message-ID: <20160426.173803.2282010417115434583.davem@davemloft.net>
References: <1461702386-17490-1-git-send-email-jannh@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jannh@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbcDZViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:38:08 -0400
In-Reply-To: <1461702386-17490-1-git-send-email-jannh@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jann Horn <jannh@google.com>
Date: Tue, 26 Apr 2016 22:26:26 +0200

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

Applied and queued up for -stable, thanks Jann.
