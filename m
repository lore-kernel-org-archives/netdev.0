From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH net-next 2/5] bpf: move clearing of A/X into classic to
 eBPF migration prologue
Date: Thu, 17 Dec 2015 16:00:45 -0800
Message-ID: <CABg9mcuVj7XL=3LyQHxjep_k4eBYe7OcV3W4jrOzXrHaD6iCaA@mail.gmail.com>
References: <cover.1450391511.git.daniel@iogearbox.net>
	<59015f2db8fe71c235fe2c19714448601136d5f9.1450391511.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Network Development <netdev@vger.kernel.org>,
	Yang Shi <yang.shi@linaro.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36339 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbbLRAAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 19:00:46 -0500
Received: by mail-io0-f194.google.com with SMTP id q126so59775iof.3
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 16:00:46 -0800 (PST)
In-Reply-To: <59015f2db8fe71c235fe2c19714448601136d5f9.1450391511.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 2:51 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Back in the days where eBPF (or back then "internal BPF" ;->) was not
> exposed to user space, and only the classic BPF programs internally
> translated into eBPF programs, we missed the fact that for classic BPF
> A and X needed to be cleared. It was fixed back then via 83d5b7ef99c9
> ("net: filter: initialize A and X registers"), and thus classic BPF
> specifics were added to the eBPF interpreter core to work around it.
>
> This added some confusion for JIT developers later on that take the
> eBPF interpreter code as an example for deriving their JIT. F.e. in
> f75298f5c3fe ("s390/bpf: clear correct BPF accumulator register"), at
> least X could leak stack memory. Furthermore, since this is only needed
> for classic BPF translations and not for eBPF (verifier takes care
> that read access to regs cannot be done uninitialized), more complexity
> is added to JITs as they need to determine whether they deal with
> migrations or native eBPF where they can just omit clearing A/X in
> their prologue and thus reduce image size a bit, see f.e. cde66c2d88da
> ("s390/bpf: Only clear A and X for converted BPF programs"). In other
> cases (x86, arm64), A and X is being cleared in the prologue also for
> eBPF case, which is unnecessary.
>
> Lets move this into the BPF migration in bpf_convert_filter() where it
> actually belongs as long as the number of eBPF JITs are still few. It
> can thus be done generically; allowing us to remove the quirk from
> __bpf_prog_run() and to slightly reduce JIT image size in case of eBPF,
> while reducing code duplication on this matter in current(/future) eBPF
> JITs.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Reviewed-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Tested-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Cc: Zi Shen Lim <zlim.lnx@gmail.com>
> Cc: Yang Shi <yang.shi@linaro.org>
> ---
>  arch/arm64/net/bpf_jit_comp.c |  6 ------

For the arm64 bits:
Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>
