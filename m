From: Tom Herbert <tom@herbertland.com>
Subject: Code quality and XDP
Date: Sat, 8 Oct 2016 07:25:01 +0900
Message-ID: <CALx6S37LyR7NGkmxFrP67GVPsyke+BM9eZm0PSw+vQo3+wjSuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33130 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752721AbcJGWZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 18:25:02 -0400
Received: by mail-qk0-f178.google.com with SMTP id n189so55185053qke.0
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2016 15:25:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One concern raised at netdev concerning XDP is how are we going to
maintain code quality, security, and correctness of programs being
loaded. With kernel bypass it is not just the kernel code path that is
being bypassed, but also the processes that hold the quality of code
being accepted to a high bar. Our users expect that quality to be
maintained.

I suggest that we need XDP programs to be subject to the same scrutiny
that any other kernel netdev code is. One idea is to sign programs
that have been accepted into the kernel. By default only signed
programs would be allowed to be loaded, the override to allow unsigned
programs might be a kernel config or a least a boot parameter
(enabling the override needs to be very explicit).

The acceptable XDP programs should probably be under their own
directory. Such a directory should only contain kernel code, not
userspace code also as is currently in samples/bpf.

A nice side effect of this model is when the same XDP programs are
being used in non-Linux environments (HW offload, other OSes, etc.)
the process could maintain quality expections in those environments
also.

Tom
