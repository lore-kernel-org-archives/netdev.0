From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH net-next] bpf, seccomp: prepare for upcoming criu support
Date: Fri, 2 Oct 2015 09:06:03 -0600
Message-ID: <20151002150603.GM23065@smitten>
References: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@parallels.com>,
	Kees Cook <keescook@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35910 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbbJBPGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 11:06:06 -0400
Received: by igcrk20 with SMTP id rk20so19233986igc.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 08:06:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Fri, Oct 02, 2015 at 03:17:33PM +0200, Daniel Borkmann wrote:
> The current ongoing effort to dump existing cBPF seccomp filters back
> to user space requires to hold the pre-transformed instructions like
> we do in case of socket filters from sk_attach_filter() side, so they
> can be reloaded in original form at a later point in time by utilities
> such as criu.
> 
> To prepare for this, simply extend the bpf_prog_create_from_user()
> API to hold a flag that tells whether we should store the original
> or not. Also, fanout filters could make use of that in future for
> things like diag. While fanout filters already use bpf_prog_destroy(),
> move seccomp over to them as well to handle original programs when
> present.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tycho Andersen <tycho.andersen@canonical.com>

Thanks for this patch. When I rebase my tree on top of it it works
fine,

Tested-by: Tycho Andersen <tycho.andersen@canonical.com>

> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  This is in realtion to Tycho's latest patch set under [1]. The BPF
>  handling is unfortunately not correct (triggering a crash on kernels
>  that can set pages as ro).
> 
>  This patch here provides a minimal, simple interface from BPF API side
>  as a possible step forward, so that the focus can then be on seccomp
>  side wrt criu. F.e., dumping could happen similarly as in Pavel's
>  sk_get_filter().
> 
>  I have tested/based this against net-next, but have no issues whether
>  Kees wants to take it, or whether it should go through both trees to
>  reduce merge issues as once the case with 0fc174dea545 ("ebpf: make
>  internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs").

I'll send out a revised version of my set with Andy's comments later
today and not include this patch. Let me know if I should do something
differently.

Thanks,

Tycho
