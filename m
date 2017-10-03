From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC 1/2] bpf: move instruction printing into a separate file
Date: Tue, 3 Oct 2017 13:14:54 -0700
Message-ID: <20171003201452.elth55atpquesjjk@ast-mbp.dhcp.thefacebook.com>
References: <59D3B456.4020209@iogearbox.net>
 <20171003175746.30145-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, dsahern@gmail.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, david.beckett@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:50135 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbdJCUO4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 16:14:56 -0400
Received: by mail-pf0-f182.google.com with SMTP id l188so5130323pfc.6
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 13:14:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171003175746.30145-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 10:57:45AM -0700, Jakub Kicinski wrote:
> Separate the instruction printing into a standalone source file.
> This way sneaky code from tools/ can use it directly.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> Like this?
...
> +static void print_bpf_end_insn(void (*verbose)(const char *, ...),
> +			       const struct bpf_insn *insn)
> +{
> +	verbose("(%02x) r%d = %s%d r%d\n", insn->code, insn->dst_reg,
> +		BPF_SRC(insn->code) == BPF_TO_BE ? "be" : "le",
> +		insn->imm, insn->dst_reg);
> +}
...
> +			print_bpf_insn(verbose, insn, env->allow_ptr_leaks);

since you're changing it please please please kill that global verbose() ugliness.
It's been on todo list for long time.
iirc that's the only thing that prevents us to remove global bpf_verifier_lock.
if we don't do it as part of this change, we'd need another one in the future
with equal amount of changed lines, so let's do it now.
