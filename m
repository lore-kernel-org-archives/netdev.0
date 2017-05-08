From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: don't let ldimm64 leak map addresses on
 unprivileged
Date: Mon, 8 May 2017 10:18:40 -0700
Message-ID: <20170508171838.t5v32fazpiiadji2@ast-mbp.dhcp.thefacebook.com>
References: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jannh@google.com, kafai@fb.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33873 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752179AbdEHRSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 13:18:43 -0400
Received: by mail-pg0-f54.google.com with SMTP id u28so26370674pgn.1
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 10:18:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 08, 2017 at 12:04:09AM +0200, Daniel Borkmann wrote:
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

thanks for the fix!

Acked-by: Alexei Starovoitov <ast@kernel.org>
