From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 0/3] Fixes for XDP/BPF
Date: Fri, 08 Sep 2017 14:00:05 -0700
Message-ID: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
        daniel@iogearbox.net, ast@fb.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32769 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756901AbdIHVAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:00:24 -0400
Received: by mail-pf0-f196.google.com with SMTP id h4so1938693pfk.0
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:00:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following fixes, UAPI updates, and small improvement,

i. XDP needs to be called inside RCU with preempt disabled.

ii. Not strictly a bug fix but we have an attach command in the
sockmap UAPI already to avoid having a single kernel released with
only the attach and not the detach I'm pushing this into net branch.
Its early in the RC cycle so I think this is OK (not ideal but better
than supporting a UAPI with a missing detach forever).

iii. Final patch replace cpu_relax with cond_resched in devmap.

---

John Fastabend (3):
      net: rcu lock and preempt disable missing around generic xdp
      bpf: add support for sockmap detach programs
      bpf: devmap, use cond_resched instead of cpu_relax


 include/linux/bpf.h                     |    8 ++---
 kernel/bpf/devmap.c                     |    2 +
 kernel/bpf/sockmap.c                    |    2 +
 kernel/bpf/syscall.c                    |   27 ++++++++++------
 net/core/dev.c                          |   25 ++++++++++-----
 tools/testing/selftests/bpf/test_maps.c |   51 ++++++++++++++++++++++++++++++-
 6 files changed, 89 insertions(+), 26 deletions(-)
