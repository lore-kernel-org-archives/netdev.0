From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/4] bpf: move context info out of the verifier
Date: Mon, 16 Oct 2017 16:40:52 -0700
Message-ID: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:57218 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932483AbdJPXlH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 19:41:07 -0400
Received: by mail-pg0-f53.google.com with SMTP id m18so8065507pgd.13
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 16:41:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Daniel pointed out during the review of my previous patchset that
the knowledge about context doesn't really belong directly in the
verifier.  This patch set takes a bit of a drastic approach to
move the info out of there.  I want to be able to use different
set of verifier_ops for program analysis.  To do that, I have
to first move the test_run callback to a separate structure.  Then
verifier ops can be declared in the verifier directly and
different sets can be picked for verification vs analysis.

Jakub Kicinski (4):
  bpf: split verifier and program ops
  bpf: remove the verifier ops from program structure
  bpf: move knowledge about post-translation offsets out of verifier
  bpf: allow access to skb->len from offloads

 include/linux/bpf.h          | 17 ++++++---
 include/linux/bpf_types.h    | 28 +++++++-------
 include/linux/bpf_verifier.h |  1 +
 kernel/bpf/syscall.c         |  6 +--
 kernel/bpf/verifier.c        | 70 +++++++++++++++--------------------
 kernel/trace/bpf_trace.c     | 15 ++++++--
 net/core/filter.c            | 87 +++++++++++++++++++++++++++++++++++++++-----
 7 files changed, 149 insertions(+), 75 deletions(-)

-- 
2.14.1
