From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 0/2] sockmap fixes
Date: Fri, 27 Oct 2017 09:45:16 -0700
Message-ID: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, daniel@iogearbox.net
To: alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:43016 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932390AbdJ0Qp3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 12:45:29 -0400
Received: by mail-pf0-f196.google.com with SMTP id a8so5348921pfc.0
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 09:45:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last two fixes (as far as I know) for sockmap code this round.

First, we are using the qdisc cb structure when making the data end
calculation. This is really just wrong so, store it with the other
metadata in the correct tcp_skb_cb sturct to avoid breaking things.

Next, with recent work to attach multiple programs to a cgroup a
specific enumeration of return codes was agreed upon. However,
I wrote the sk_skb program types before seeing this work and used
a different convention. Patch 2 in the series aligns the return
codes to avoid breaking with this infrastructure and also aligns
with other programming conventions to avoid being the odd duck out
forcing programs to remember SK_SKB programs are different. Pusing
to net because its a user visible change. With this SK_SKB program
return codes are the same as other cgroup program types.

Thanks!
John

---

John Fastabend (2):
      bpf: bpf_compute_data uses incorrect cb structure
      bpf: rename sk_actions to align with bpf infrastructure


 include/net/tcp.h              |    1 +
 include/uapi/linux/bpf.h       |    6 +++---
 kernel/bpf/sockmap.c           |   15 ++++++++++++---
 net/core/filter.c              |   32 +++++++++++++++++++++++++++++---
 tools/include/uapi/linux/bpf.h |    4 ++--
 5 files changed, 47 insertions(+), 11 deletions(-)
