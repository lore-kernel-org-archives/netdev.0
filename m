From: Tom Herbert <tom@herbertland.com>
Subject: Update on XDP
Date: Tue, 31 May 2016 14:22:08 -0700
Message-ID: <CALx6S37q7RFJgLtKDNB6EuOBZaVJ03-Lp8eEZBRcgvJgBbyNVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34319 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbcEaVWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 17:22:09 -0400
Received: by mail-io0-f193.google.com with SMTP id l9so499910ioe.1
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 14:22:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev,

XDP (eXpress Data Path) is a high performance, programmable network
data path that is being developed as a community effort (initially
within IO-visor). XDP will be useful for packet processing in
forwarding, load balancing, DOS mitigation, firewalls, etc. See
https://github.com/iovisor/bpf-docs/blob/master/Express_Data_Path.pdf
for a description.

To achieve high performance, XDP runs as a thin layer at this lowest
levels of the stack with minimal infrastructure. For instance, in
Linux, XDP runs directly of the device drivers and operates directly
on receive buffers and an abstracted receive descriptor instead of
skbufs. XDP does not require specialized hardware, but does allow
leveraging various advanced HW features.

Programmability in XDP is provided by BPF,  a small set of helper
functions, and a well defined input-output API. XDP is intended to be
platform agnostic following the principle of "write once, run
anywhere", so we are expecting that XDP programs can run in the OS
(Linux and others), HW (via offload), or in userspace (over DPDK for
instance).

We have made some good progress in the Linux implementation and are
able to demonstrate single CPU packet drop performance in excess of
14M pps, and packet forwarding in excess of 10M pps. Work on real
world use cases is commencing-- L4 load balancer, DOS mitigation, and
an ILA router. We hope to have patches posted and a more detailed
introduction of XDP for netdev 1.2.

If you are interested in XDP development and discussion please join
the iovisor-dev mailing list. Also, we will be holding an XDP summit
on June 23-- if you are actively working on XDP right now, or believe
that work on XDP is imminent, please contact me about an invitation.

Thanks,
Tom
