From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf, seccomp: prepare for upcoming criu support
Date: Fri, 2 Oct 2015 08:09:50 -0700
Message-ID: <560E9E3E.2080000@plumgrid.com>
References: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Kees Cook <keescook@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34866 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbJBPJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 11:09:51 -0400
Received: by pacfv12 with SMTP id fv12so111132492pac.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 08:09:50 -0700 (PDT)
In-Reply-To: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/15 6:17 AM, Daniel Borkmann wrote:
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
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

I agree that adding flag to bpf_prog_create_from_user() is cleaner
than exposing static bpf_prog_store_orig_filter(), so
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
