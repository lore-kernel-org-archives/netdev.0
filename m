From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: don't let ldimm64 leak map addresses on
 unprivileged
Date: Mon, 08 May 2017 15:08:48 -0400 (EDT)
Message-ID: <20170508.150848.820947666682881837.davem@davemloft.net>
References: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, jannh@google.com, kafai@fb.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35512 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753948AbdEHTIu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:08:50 -0400
In-Reply-To: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon,  8 May 2017 00:04:09 +0200

> The patch fixes two things at once:
> 
> 1) It checks the env->allow_ptr_leaks and only prints the map address to
>    the log if we have the privileges to do so, otherwise it just dumps 0
>    as we would when kptr_restrict is enabled on %pK. Given the latter is
>    off by default and not every distro sets it, I don't want to rely on
>    this, hence the 0 by default for unprivileged.
> 
> 2) Printing of ldimm64 in the verifier log is currently broken in that
>    we don't print the full immediate, but only the 32 bit part of the
>    first insn part for ldimm64. Thus, fix this up as well; it's okay to
>    access, since we verified all ldimm64 earlier already (including just
>    constants) through replace_map_fd_with_map_ptr().
> 
> Fixes: cbd357008604 ("bpf: verifier (add ability to receive verification log)")
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, with second Fixes: tag added, and queued up for -stable.

Thanks.
