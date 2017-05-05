From: Tom Herbert <tom@herbertland.com>
Subject: SSE instructions for fast packet copy?
Date: Thu, 4 May 2017 22:50:51 -0700
Message-ID: <CALx6S34r6Q_wCKqzv5YjKJyuETyYmY1y=M7uDYiLfpnXzqbheg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33474 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751079AbdEEFux (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 01:50:53 -0400
Received: by mail-qk0-f179.google.com with SMTP id n4so27869903qkc.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 22:50:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am thinking about the possibility of using SSE in kernel for
speeding up the kernel memcpy particularly for copy to userspace
emeory, and maybe even using the string instructions (like if we
supported regex in something like eBPF). AFAIK we don't use SSE in
kernel because of xmm register state needing to be saved across
context switch. However, if we start busy-polling a CPU in kernel on
network queues then there might not be any context switches to worry
about. In this model we'd want to enable SSE per CPU.

Has this ever been tried before? Is this at all feasible? :-) Is it
possible to enable SSE for kernel for just one CPU? (I found CPUID
will return SSE supported, but don't see how to enable other than
-msse for compiling).

Thanks,
Tom
