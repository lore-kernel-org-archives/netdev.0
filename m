From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Fri, 23 Sep 2016 07:14:57 -0700
Message-ID: <CALx6S36rFUaaeFU4sE7gNaPn2Jxf-FaOESy_rrDpLKRx-SWkDA@mail.gmail.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com> <06280af8-5451-c423-d295-a5f3f51e63cf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34545 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760048AbcIWOO7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 10:14:59 -0400
Received: by mail-qt0-f195.google.com with SMTP id e5so3556811qtb.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 07:14:58 -0700 (PDT)
In-Reply-To: <06280af8-5451-c423-d295-a5f3f51e63cf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 4:13 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-09-20 06:00 PM, Tom Herbert wrote:
>>
>> This patch creates an infrastructure for registering and running code at
>> XDP hooks in drivers. This is based on the orignal XDP?BPF and borrows
>> heavily from the techniques used by netfilter to make generic nfhooks.
>>
>> An XDP hook is defined by the  xdp_hook_ops. This structure contains the
>> ops of an XDP hook. A pointer to this structure is passed into the XDP
>> register function to set up a hook. The XDP register function mallocs
>> its own xdp_hook_ops structure and copies the values from the
>> xdp_hook_ops passed in. The register function also stores the pointer
>> value of the xdp_hook_ops argument; this pointer is used in subsequently
>> calls to XDP to identify the registered hook.
>>
>> The interface is defined in net/xdp.h. This includes the definition of
>> xdp_hook_ops, functions to register and unregister hook ops on a device
>> or individual instances of napi, and xdp_hook_run that is called by
>> drivers to run the hooks.
>>
>
> Tom,
> perused the thread and it seems you are serious ;->
> Are we heading towards Frankenstein Avenue?

I'm surprised. I thought you'd like democratizing an interface. :-)

> The whole point behind letting in XDP is so that _small programs_
> can be written to do some quick thing. eBPF 4K program limit was
> touted as the check and bound. eBPF sounded fine.
> This sounds like a huge contradiction.

Jamal, thanks for the feedback.

IMO, XDP != BPF. XDP is an interface in drivers that allow raw packet
processing in the receive path,. This is akin to DPDK in the kernel.
BPF is critical use case of the interface.

As for the 4K limit that still allows for a lot of damage and abuse
that the user can do with a loadable program and, yes, code in the
kernel can do significant damage as well. However, unlike BPF programs
being set from userspace, kernel code has a well established process
for acceptance, any suggested code gets review, and if it's going
"Frankenstein Avenue" I'd expect it to be rejected. I get a little
worried that we are going to start artificially limiting what we can
do in the kernel on the basis that we don't trust kernel programmers
to be competent enough not to abuse kernel interfaces-- the fact that
we are enabling userspace to arbitrarily program the kernel but
purposely limiting what the kernel itself can do would be a huge irony
to me.

Thanks,
Tom




>
> cheers,
> jamal
>
>
