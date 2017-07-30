From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix bpf_prog_get_info_by_fd to dump correct
 xlated_prog_len
Date: Sat, 29 Jul 2017 23:30:37 -0700 (PDT)
Message-ID: <20170729.233037.568661796030410786.davem@davemloft.net>
References: <a88afb3f19e16a937683bc2bfa80100144fb3792.1501254197.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47736 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdG3Gaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 02:30:39 -0400
In-Reply-To: <a88afb3f19e16a937683bc2bfa80100144fb3792.1501254197.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 28 Jul 2017 17:05:25 +0200

> bpf_prog_size(prog->len) is not the correct length we want to dump
> back to user space. The code in bpf_prog_get_info_by_fd() uses this
> to copy prog->insnsi to user space, but bpf_prog_size(prog->len) also
> includes the size of struct bpf_prog itself plus program instructions
> and is usually used either in context of accounting or for bpf_prog_alloc()
> et al, thus we copy out of bounds in bpf_prog_get_info_by_fd()
> potentially. Use the correct bpf_prog_insn_size() instead.
> 
> Fixes: 1e2709769086 ("bpf: Add BPF_OBJ_GET_INFO_BY_FD")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
