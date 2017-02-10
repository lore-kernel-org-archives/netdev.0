From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 9 Feb 2017 20:55:34 -0800
Message-ID: <CALx6S3695kv=Rr9V48k_CByCGvXLKzoM2XgpHiysB+cpaA4tzg@mail.gmail.com>
References: <CALx6S368wyPdLkyvAhFG3BXJFJifFSJSK+x__2sQr1rGeP8aRw@mail.gmail.com>
 <20170209.204229.1662524081519832785.davem@davemloft.net> <CALx6S37_GOP4a0x2aVbde1ynZRxDXx3A+YfY6sMMEZQEKN_1+g@mail.gmail.com>
 <20170209.223348.2143869696524078186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33183 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751071AbdBJF1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 00:27:15 -0500
Received: by mail-qk0-f196.google.com with SMTP id 11so3695667qkl.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 21:27:15 -0800 (PST)
In-Reply-To: <20170209.223348.2143869696524078186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 7:33 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 9 Feb 2017 18:29:54 -0800
>
>> So we have thousands or LOC coming into drivers every day anyway with
>> all those properties anyway, so this "restricted" environment solves
>> at best 1% of the problem.
>
> What you must understand is that no matter what someone outside of
> upstream writes into an eBPF program, it's safe, and we can absolutely
> prove this with the verifier and the invariants of the execution
> environment.
>
This is the exact same argument the userspace stack proponents will
use-- put your stack in userspace and you can't crash the host. But
just like eBPF that does not at all mean the logic of the program is
correct. Getting into a mode where we drop every packet, or checksums
are miscomputed, or a protocol field is miswritten is entirely
possible. The value of coding in the Linux kernel, maybe the only
truly relevant point compared to userspace stacks, is the scrutiny,
the testing, the debugging, and the eyes of experts we get to look at
every line going into the kernel to avoid such problems. Even though
there's the possibility of crash or deadloacking the system, I would
absolutely put the quality of kernel code over _any_ piece of
userspace code _any_ day of the week. Maybe some day we'll see a
process for XDP/BPF for reviewing and accepting code and you along
with several of established experts on netdev will be earnestly
reviewing such code, but until then I am more inclined to stick with
writing kernel code for anything other than simple things that are
amenable to BPF. The problem with kernel bypass is not just that it
bypasses the well-written and well-tested kernel code, but that it
also bypasses the process.

Tom
