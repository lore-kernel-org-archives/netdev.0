From: Jeffrey Vander Stoep <jeffv@google.com>
Subject: Permissions for eBPF objects
Date: Fri, 25 Aug 2017 11:01:16 -0700
Message-ID: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Chenbo Feng <fengc@google.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:36068 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754845AbdHYSBS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 14:01:18 -0400
Received: by mail-qt0-f171.google.com with SMTP id v29so2642167qtv.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 11:01:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I=E2=80=99d like to get your thoughts on adding LSM permission checks on BP=
F objects.

By default, the ability to create and use eBPF maps/programs requires
CAP_SYS_ADMIN [1]. Alternatively, all processes can be granted access
to bpf() functions. This seems like poor granularity. [2]

Like files and sockets, eBPF maps and programs can be passed between
processes by FD and have a number of functions that map cleanly to
permissions.

Let me know what you think. Are there simpler alternative approaches
that we haven=E2=80=99t considered?

Thanks!
Jeff

[1] http://man7.org/linux/man-pages/man2/bpf.2.html NOTES section
[2] We are considering eBPF for network filtering by netd. Giving netd
CAP_SYS_ADMIN would considerably increase netd=E2=80=99s privileges.
Alternatively allowing all processes permission to use bpf() goes
against the principle of least privilege exposing a lot of kernel
attack surface to processes that do not actually need it.
