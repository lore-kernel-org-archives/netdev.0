From: William Tu <u9012063@gmail.com>
Subject: Re: [RFC PATCH net-next] bpf: fix potential percpu map overcopy to user.
Date: Thu, 20 Oct 2016 12:21:31 -0700
Message-ID: <CALDO+Sa1VNO9tgq9PRWnKc8ORB0VSqKZMDZya=HgUtsKGVhQUQ@mail.gmail.com>
References: <1476636088-9268-1-git-send-email-u9012063@gmail.com>
 <20161019005004.GA87961@ast-mbp.thefacebook.com> <CALDO+SaebqahYHn2PU=nk6mYOMjRp+F8PKb3cFaGMv4_xjLwZg@mail.gmail.com>
 <58074581.1000601@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34165 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754941AbcJTTWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 15:22:13 -0400
Received: by mail-it0-f67.google.com with SMTP id e203so7604079itc.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 12:22:12 -0700 (PDT)
In-Reply-To: <58074581.1000601@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Documentation/cputopology.txt +106 says /sys/devices/system/cpu/possible
> outputs cpu_possible_mask. That is the same as in num_possible_cpus(), so
> first step would be to fix the buggy example code, imho.
>
> What perhaps could be done in a second step to reduce overhead is an option
> for bpf(2) to pass in a cpu mask similarly as for sched_{get,set}affinity()
> syscalls, where user space can construct a mask via CPU_SET(3). For the
> syscall time, kernel would lock hot plugging via get_online_cpus() and
> put_online_cpus(), it would check whether passed CPUs are online to query
> and if so then it would copy the values into the user provided buffer. I'd
> think this might be useful in a number of ways anyway.
>

I like this idea. So in this case, the only the data at the cpu
specified by user in the CPU_SET is copied to userspace, potentially
have better performance than always copying the data *
num_possible_cpus() bytes.

Regards,
William
