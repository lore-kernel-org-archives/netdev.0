From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 9 Feb 2017 14:26:50 -0800
Message-ID: <CALx6S34qGUd7Zteo_sDdcXK69cOZUwiQ6wsbLfiyHW1K6gJn=A@mail.gmail.com>
References: <20170208234127.3041579-1-tom@herbertland.com> <20170208234127.3041579-2-tom@herbertland.com>
 <20170209.171706.1575416693138040726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34770 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752432AbdBIW1C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 17:27:02 -0500
Received: by mail-qk0-f196.google.com with SMTP id e1so2708323qkh.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 14:26:51 -0800 (PST)
In-Reply-To: <20170209.171706.1575416693138040726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 2:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 8 Feb 2017 15:41:20 -0800
>
>> These hooks are also generic to allow for XDP/BPF programs as well
>> as non-BPF code (e.g. kernel code can be written in a module).
>
> I don't think we should even remotely consider surrendering the XDP
> hook to module code.
>
> We restrict it to eBPF for a reason, because that framework is
> restricted in what it can do, what it can access, and how it can do
> so.
>
Kernel modules go through extensive netdev review before they are
taken into the kernel, for BPF programs we just allow what any user
gives us without any peer review even implied. For this reason, I
simply don't believe that BPF is magically more robust code than what
is in a kernel module. Or to put it another way, do you think DPDK is
going to put any restrictions on what a user can do over raw queues in
userspace? If we put on artificial limits on XDP like it can only ever
be BPF then we are just closing the door to its full potential and
given more fodder for the userpace stacks to claim superiority.

> Tom if you're going to do a cleanup that makes it so that drivers
> need less code to support XDP, that is awesome but please do only
> that.
>
> Don't combine it with more controversial changes.
>
We need this for TXDP; I have no interest in rewriting the TCP stack in BPF :-)

Tom

> Thank you.
