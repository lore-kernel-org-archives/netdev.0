From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/5] BPF updates
Date: Wed, 13 Apr 2016 00:10:49 +0200
Message-ID: <cover.1460497071.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, bblanco@plumgrid.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34329 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933102AbcDLWLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:11:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a new verifier argument type called
ARG_PTR_TO_RAW_STACK and converts related helpers to make
use of it. Basic idea is that we can save init of stack
memory when the helper function is guaranteed to fully
fill out the passed buffer in every path. Series also adds
test cases and converts samples. For more details, please
see individual patches.

Thanks!

Daniel Borkmann (5):
  bpf, verifier: add bpf_call_arg_meta for passing meta data
  bpf, verifier: add ARG_PTR_TO_RAW_STACK type
  bpf: convert relevant helper args to ARG_PTR_TO_RAW_STACK
  bpf, samples: don't zero data when not needed
  bpf, samples: add test cases for raw stack

 include/linux/bpf.h            |   5 +
 kernel/bpf/helpers.c           |  17 ++-
 kernel/bpf/verifier.c          |  97 +++++++++++----
 kernel/trace/bpf_trace.c       |  10 +-
 net/core/filter.c              |  57 ++++++---
 samples/bpf/offwaketime_kern.c |  10 +-
 samples/bpf/test_verifier.c    | 268 +++++++++++++++++++++++++++++++++++++++++
 samples/bpf/tracex1_kern.c     |   4 +-
 samples/bpf/tracex2_kern.c     |   4 +-
 samples/bpf/tracex5_kern.c     |   6 +-
 10 files changed, 421 insertions(+), 57 deletions(-)

-- 
1.9.3
