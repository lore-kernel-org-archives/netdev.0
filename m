From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next v2 2/2] tc: add eBPF support to f_bpf
Date: Tue, 24 Mar 2015 15:27:20 -0700
Message-ID: <20150324152720.4c04090b@urahara>
References: <cover.1426530729.git.daniel@iogearbox.net>
	<e6ccd2548197c60c0686dca78ae02fc604fde065.1426530729.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jiri@resnulli.us, ast@plumgrid.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35464 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbbCXW1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:27:18 -0400
Received: by pdbop1 with SMTP id op1so7072354pdb.2
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:27:17 -0700 (PDT)
In-Reply-To: <e6ccd2548197c60c0686dca78ae02fc604fde065.1426530729.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Mar 2015 19:37:41 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> This work adds the tc frontend for kernel commit e2e9b6541dd4 ("cls_bpf:
> add initial eBPF support for programmable classifiers").
> 
> A C-like classifier program (f.e. see e2e9b6541dd4) is being compiled via
> LLVM's eBPF backend into an ELF file, that is then being passed to tc. tc
> then loads, if any, eBPF maps and eBPF opcodes (with fixed-up eBPF map file
> descriptors) out of its dedicated sections, and via bpf(2) into the kernel
> and then the resulting fd via netlink down to cls_bpf. cls_bpf allows for
> annotations, currently, I've used the file name for that, so that the user
> can easily identify his filter when dumping configurations back.
> 
> Example usage:
> 
>   clang -O2 -emit-llvm -c cls.c -o - | llc -march=bpf -filetype=obj -o cls.o
>   tc filter add dev em1 parent 1: bpf run object-file cls.o classid x:y
> 
>   tc filter show dev em1 [...]
>   filter parent 1: protocol all pref 49152 bpf handle 0x1 flowid x:y cls.o
> 
> I placed the parser bits derived from Alexei's kernel sample, into tc_bpf.c
> as my next step is to also add the same support for BPF action, so we can
> have a fully fledged eBPF classifier and action in tc.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied to net-next of iproute2
