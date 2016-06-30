From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] Further robustify putting BPF progs
Date: Thu, 30 Jun 2016 17:24:42 +0200
Message-ID: <cover.1467298256.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, jannh@google.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48315 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454AbcF3PZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:25:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses a potential issue reported to us by Jann Horn
with regards to putting progs. First patch moves progs generally under
RCU destruction and second patch refactors getting of progs to simplify
code a bit. For details, please see individual patches. Note, we think
that addressing this one in net-next should be sufficient.

Thanks!

Daniel Borkmann (2):
  bpf: generally move prog destruction to RCU deferral
  bpf: refactor bpf_prog_get and type check into helper

 include/linux/bpf.h    |  8 +++++---
 kernel/bpf/arraymap.c  |  4 +---
 kernel/bpf/syscall.c   | 40 ++++++++++++++++++++++------------------
 kernel/events/core.c   |  2 +-
 net/core/filter.c      | 13 +------------
 net/kcm/kcmsock.c      |  8 +-------
 net/packet/af_packet.c |  6 +-----
 net/sched/act_bpf.c    |  7 +------
 net/sched/cls_bpf.c    |  7 +------
 9 files changed, 34 insertions(+), 61 deletions(-)

-- 
1.9.3
