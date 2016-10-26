From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: fix samples to add fake KBUILD_MODNAME
Date: Tue, 25 Oct 2016 18:17:15 -0700
Message-ID: <20161026011713.GA35732@ast-mbp.thefacebook.com>
References: <1fdac65566ed6e0cff486507c5019f45807d1e89.1477434641.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36406 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752215AbcJZBR1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 21:17:27 -0400
Received: by mail-pf0-f193.google.com with SMTP id n85so1942736pfi.3
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 18:17:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1fdac65566ed6e0cff486507c5019f45807d1e89.1477434641.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 12:37:53AM +0200, Daniel Borkmann wrote:
> Some of the sample files are causing issues when they are loaded with tc
> and cls_bpf, meaning tc bails out while trying to parse the resulting ELF
> file as program/map/etc sections are not present, which can be easily
> spotted with readelf(1).
> 
> Currently, BPF samples are including some of the kernel headers and mid
> term we should change them to refrain from this, really. When dynamic
> debugging is enabled, we bail out due to undeclared KBUILD_MODNAME, which
> is easily overlooked in the build as clang spills this along with other
> noisy warnings from various header includes, and llc still generates an
> ELF file with mentioned characteristics. For just playing around with BPF
> examples, this can be a bit of a hurdle to take.
> 
> Just add a fake KBUILD_MODNAME as a band-aid to fix the issue, same is
> done in xdp*_kern samples already.
> 
> Fixes: 65d472fb007d ("samples/bpf: add 'pointer to packet' tests")
> Fixes: 6afb1e28b859 ("samples/bpf: Add tunnel set/get tests.")
> Fixes: a3f74617340b ("cgroup: bpf: Add an example to do cgroup checking in BPF")
> Reported-by: Chandrasekar Kannan <ckannan@console.to>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  samples/bpf/parse_ldabs.c        | 1 +
>  samples/bpf/parse_simple.c       | 1 +
>  samples/bpf/parse_varlen.c       | 1 +
>  samples/bpf/tcbpf1_kern.c        | 1 +
>  samples/bpf/tcbpf2_kern.c        | 1 +
>  samples/bpf/test_cgrp2_tc_kern.c | 1 +
>  6 files changed, 6 insertions(+)

It's also needed for all of tracex*_kern.c, right?

For networking samlpes we probably should get rid of kernel headers.
I guess they were there by copy-paste mistake from tracing, since
tracing samples actually need to include them, since they do bpf_probe_read
into kernel data structures.
For this patch in the mean time:
Acked-by: Alexei Starovoitov <ast@kernel.org>
