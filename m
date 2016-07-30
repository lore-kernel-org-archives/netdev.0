From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Fri, 29 Jul 2016 22:34:16 -0700
Message-ID: <20160730053415.GA78880@ast-mbp.thefacebook.com>
References: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
 <20160729064722.GA54517@ast-mbp.thefacebook.com>
 <579B0B9F.8040805@iogearbox.net>
 <CALDO+SZueK9ymNjrLAK+00xzR_BTms+qVhy0DAPnJZGrken2rg@mail.gmail.com>
 <579BF2A1.7000709@iogearbox.net>
 <CALDO+SbhCuc85b=UuSWVc7baScN+MNwwaLKcXeubPL1SJvOT=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34202 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcG3FeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 01:34:23 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so6556909pfb.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 22:34:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALDO+SbhCuc85b=UuSWVc7baScN+MNwwaLKcXeubPL1SJvOT=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2016 at 10:23:06PM -0700, William Tu wrote:
> On Fri, Jul 29, 2016 at 5:19 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> > On 07/29/2016 10:03 PM, William Tu wrote:
> >>
> >> I'm not using ARM. It's x86 in a VM with 2 vcpu. By printk() in kernel, I
> >> got
> >>    num_possible_cpu == 64
> >>    num_online_cpu == 2 == sysconf(_SC_NPROCESSORS_CONF)
...
> >> To fix it, I could either
> >> 1). declare values array based on num_possible_cpu in test_map.c,
> >>    long values[64];
> >> or 2) in kernel, only copying 8*2 = 16 byte from kernel to user.
...
> Since percpu array adds variable length of data passing between kernel
> and userspace, I wonder if we should add a 'value_len' field in 'union
> bpf_attr' so kernel knows how much data to copy to user?

I think the first step is to figure out why num_possible is 64,
since it hurts all per-cpu allocations. If it is a widespread issue,
it hurts a lot of VMs.
Hopefully it's not the case, since in my kvm setup num_possible==num_online
qemu version 2.4.0
booting with -enable-kvm -smp N
