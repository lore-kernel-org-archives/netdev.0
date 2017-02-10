From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 9 Feb 2017 18:30:05 -0800
Message-ID: <CALx6S37vWi_qbBzq2Anxy6Yb5mgcQjgt7TDWYJgNJJJ13qPi2g@mail.gmail.com>
References: <CALx6S34qGUd7Zteo_sDdcXK69cOZUwiQ6wsbLfiyHW1K6gJn=A@mail.gmail.com>
 <20170209.173415.1198067959393786704.davem@davemloft.net> <CALx6S36ojsMZx-TW0cMCjvK07ffymPon8FDAVKMpmFRd8R-yYw@mail.gmail.com>
 <20170209.204811.352646130146676206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36786 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750994AbdBJCae (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 21:30:34 -0500
Received: by mail-qk0-f193.google.com with SMTP id i34so3311864qkh.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 18:30:06 -0800 (PST)
In-Reply-To: <20170209.204811.352646130146676206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 5:48 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 9 Feb 2017 15:08:22 -0800
>
>> Okay, how about this... I'll add a configuration option like
>> XDP_ALLOW_OTHER_HOOKS. The default will be to disallow setting any
>> hook other than a BPF. If it is set, then we'll accept other hooks
>> to be run. This way mostly restrict the interface by default, but
>> still allow experimentation with other hook types like I need with
>> TXDP or maybe the netfilter guys might want to fastpath netfilter
>> etc. When we we bring a working robust implementation to netdev that
>> show clear benefits then we can add those to BPF as the "allowed"
>> hooks at that time. So this strictly controls the interfaces, but
>> still also allows room for innovation.
>
> Anyone is allowed to "innovate" in their own private kernel tree.
>
> But I'm not unleashing that upstream.
>
> The only reason I accepted XDP is entirely because it is limited
> in scope to eBPF.  All eBPF programs execute in finite time,
> cannot loop, cannot deadlock, cannot access arbitrary pieces
> of kernel memory and datastructures.
>
> It is a well defined, constrained, and incredibly tightly controlled
> execution environment for implementing policy, monitoring and control.

And it's also incredibly invasive in the core data path of drivers.
TBH it is not clear to me that the narrow use cases for XDP justifies
adding this complexity being added to every driver.

In any case, I withdraw the patch set.

Tom
