From: Tom Herbert <tom@herbertland.com>
Subject: Re: Code quality and XDP
Date: Sat, 8 Oct 2016 12:11:51 -0700
Message-ID: <CALx6S35wpZL+K=Rt=7jenjouYg72rkXOn3ey46sqL_3zqf98-g@mail.gmail.com>
References: <CALx6S37LyR7NGkmxFrP67GVPsyke+BM9eZm0PSw+vQo3+wjSuA@mail.gmail.com>
 <20161008062817.45d6ac2b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:35142 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbcJHTLx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2016 15:11:53 -0400
Received: by mail-qt0-f171.google.com with SMTP id f6so34186175qtd.2
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2016 12:11:52 -0700 (PDT)
In-Reply-To: <20161008062817.45d6ac2b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 7, 2016 at 9:28 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Sat, 8 Oct 2016 07:25:01 +0900 Tom Herbert <tom@herbertland.com> wrote:
>
>> One concern raised at netdev concerning XDP is how are we going to
>> maintain code quality, security, and correctness of programs being
>> loaded. With kernel bypass it is not just the kernel code path that is
>> being bypassed, but also the processes that hold the quality of code
>> being accepted to a high bar. Our users expect that quality to be
>> maintained.
>>
>> I suggest that we need XDP programs to be subject to the same scrutiny
>> that any other kernel netdev code is. One idea is to sign programs
>> that have been accepted into the kernel. By default only signed
>> programs would be allowed to be loaded, the override to allow unsigned
>> programs might be a kernel config or a least a boot parameter
>> (enabling the override needs to be very explicit).
>
> Sorry, I think this "lock-down" will kill the DDoS use-case.  In the
> DDoS mitigation use-case, is all about flexibility to adapt quickly to
> changing attacks.  Thus, you need the ability to quickly modify your
> programs to catch attack signatures.
>
As I mentioned the ability to run arbitrary programs can be explicitly
be disabled for such use-cases. But not all use cases of XDP require
such dynamic program-ability and not every user is going to need or
want this capability. For instance, an ILA router should be a
straightforward program to implement and not really need dynamic
modification (it is controlled through configuration). If someone
chooses to do a proprietary ILA router themselves they can do that by
disabling the lock-down, but they shouldn't expect any support from
the community when things got wrong. This is no different then when
people post to netdev about problems they are having with proprietary
modules. If they use an in-tree implementation then we could support
that.

Tom

>
>> The acceptable XDP programs should probably be under their own
>> directory. Such a directory should only contain kernel code, not
>> userspace code also as is currently in samples/bpf.
>>
>> A nice side effect of this model is when the same XDP programs are
>> being used in non-Linux environments (HW offload, other OSes, etc.)
>> the process could maintain quality expections in those environments
>> also.
>
> I'm not against having some 'signed' eBPF/XDP programs.  If a XDP
> programs behavior is well-defined enough, this would also open up for
> HW offloading of "programs" that does the same functionality (without
> looking at the eBPF code).
>

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
