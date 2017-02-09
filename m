From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 9 Feb 2017 14:45:04 -0800
Message-ID: <CALx6S368wyPdLkyvAhFG3BXJFJifFSJSK+x__2sQr1rGeP8aRw@mail.gmail.com>
References: <20170208234127.3041579-2-tom@herbertland.com> <20170209.171706.1575416693138040726.davem@davemloft.net>
 <CALx6S34qGUd7Zteo_sDdcXK69cOZUwiQ6wsbLfiyHW1K6gJn=A@mail.gmail.com> <20170209.173415.1198067959393786704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36807 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751030AbdBIWqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 17:46:09 -0500
Received: by mail-qt0-f193.google.com with SMTP id h53so2460164qth.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 14:45:05 -0800 (PST)
In-Reply-To: <20170209.173415.1198067959393786704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 2:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 9 Feb 2017 14:26:50 -0800
>
>> On Thu, Feb 9, 2017 at 2:17 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Tom Herbert <tom@herbertland.com>
>>> Date: Wed, 8 Feb 2017 15:41:20 -0800
>>>
>>>> These hooks are also generic to allow for XDP/BPF programs as well
>>>> as non-BPF code (e.g. kernel code can be written in a module).
>>>
>>> I don't think we should even remotely consider surrendering the XDP
>>> hook to module code.
>>>
>>> We restrict it to eBPF for a reason, because that framework is
>>> restricted in what it can do, what it can access, and how it can do
>>> so.
>>>
>> Kernel modules go through extensive netdev review before they are
>> taken into the kernel, for BPF programs we just allow what any user
>> gives us without any peer review even implied.
>
> We can actually control what externally written XDP eBPF programs can
> do, for kernel modules we have no such control or influence.  This
> hook runs right in the driver and bypasses the entire stack, it has to
> execute in a hardened thing that cannot crash and it will not as long
> as BPF verifier is correct.
>
> And you're going to make it even more complicated what XDP offload in
> hardware actually means.  With eBPF it is very clearly defined what
> the necessary execution engine is.
>
> Tom I'm strongly against being allowed to run arbitrary module code
> from the XDP hook, sorry.
>
> It is as important as the distinction between full stack offload and
> partial offload in those nice charts in your talks. :-)
>
Yes it is. And the relevant principle that I would draw from that is
the "offload" means offloading functionality from the kernel **to**
the device. Restricting what we implement in the kernel on the basis
of whether or not it can be offloaded to a device is completely
backwards in this regard.

Tom
