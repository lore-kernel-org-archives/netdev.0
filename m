From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH iproute2 -master] tc: {m,f}_ebpf: add option for dumping
 verifier log
Date: Tue, 28 Apr 2015 13:37:48 -0700
Message-ID: <553FEF9C.6010104@plumgrid.com>
References: <b312101ba95af54ffd2f4c56694c0b44ccbfa051.1430220466.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36495 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030901AbbD1Uhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:37:50 -0400
Received: by pdea3 with SMTP id a3so6229168pde.3
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:37:50 -0700 (PDT)
In-Reply-To: <b312101ba95af54ffd2f4c56694c0b44ccbfa051.1430220466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/15 4:37 AM, Daniel Borkmann wrote:
> Currently, only on error we get a log dump, but I found it useful when
> working with eBPF to have an option to also dump the log on success.
> Also spotted a typo in a header comment, which is fixed here as well.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
...
> @@ -284,8 +287,11 @@ static int bpf_prog_attach(enum bpf_prog_type type, const struct bpf_insn *insns
>   {
>   	int prog_fd = bpf_prog_load(type, insns, size, license);
>
> -	if (prog_fd < 0)
> -		bpf_dump_error("BPF program rejected: %s\n", strerror(errno));
> +	if (prog_fd < 0 || bpf_verbose) {
> +		bpf_dump_error("%s: %s\n", prog_fd < 0 ?
> +			       "BPF program rejected" :
> +			       "BPF program verification", strerror(errno));
> +	}

I have very similar hack locally that I stash/unstash periodically for
debugging. Good thing to have it in generic form.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
