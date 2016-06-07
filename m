From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH net-next v2 0/4] arm64 BPF JIT updates
Date: Mon,  6 Jun 2016 22:22:55 -0700
Message-ID: <1465276979-10147-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32903 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbcFGFXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 01:23:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updates for arm64 eBPF JIT.
The main addition here is implementation of bpf_tail_call.

#1: Fix missing header inclusion in linux/bpf.h.
#2: Add bpf_tail_call for arm64.
#3,4: Optimizations to reduce instruction count for jitted code.

Changes since v1:
 - Added patch #1 to address build error due to missing header inclusion
   in linux/bpf.h. (Thanks to suggestion and ack by Daniel Borkmann)
   Ordered it ahead of bpf_tail_call patch #2 so build error is not
   triggered.

Zi Shen Lim (4):
  bpf: fix missing header inclusion
  arm64: bpf: implement bpf_tail_call() helper
  arm64: bpf: optimize JMP_CALL
  arm64: bpf: optimize LD_ABS, LD_IND

 arch/arm64/net/bpf_jit.h      |   3 +-
 arch/arm64/net/bpf_jit_comp.c | 111 ++++++++++++++++++++++++++++++++++++------
 include/linux/bpf.h           |   1 +
 3 files changed, 99 insertions(+), 16 deletions(-)

-- 
1.9.1
