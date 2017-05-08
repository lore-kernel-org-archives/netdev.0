From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: don't let ldimm64 leak map addresses on unprivileged
Date: Mon, 08 May 2017 10:44:46 +0200
Message-ID: <59102FFE.8000701@iogearbox.net>
References: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, jannh@google.com, kafai@fb.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49335 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdEHIoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 04:44:54 -0400
In-Reply-To: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2017 12:04 AM, Daniel Borkmann wrote:
> The patch fixes two things at once:
>
> 1) It checks the env->allow_ptr_leaks and only prints the map address to
>     the log if we have the privileges to do so, otherwise it just dumps 0
>     as we would when kptr_restrict is enabled on %pK. Given the latter is
>     off by default and not every distro sets it, I don't want to rely on
>     this, hence the 0 by default for unprivileged.
>
> 2) Printing of ldimm64 in the verifier log is currently broken in that
>     we don't print the full immediate, but only the 32 bit part of the
>     first insn part for ldimm64. Thus, fix this up as well; it's okay to
>     access, since we verified all ldimm64 earlier already (including just
>     constants) through replace_map_fd_with_map_ptr().

This one is also needed for the log (should come first):

Fixes: 1be7f75d1668 ("bpf: enable non-root eBPF programs")

> Fixes: cbd357008604 ("bpf: verifier (add ability to receive verification log)")
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks,
Daniel
