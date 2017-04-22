From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 net-next 0/2] sparc64 eBPF JIT
Date: Fri, 21 Apr 2017 20:16:48 -0700 (PDT)
Message-ID: <20170421.201648.1153236027978111172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: sparclinux@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1043565AbdDVDQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 23:16:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This series adds an eBPF JIT for sparc64.

Sparc32 keeps having it's cBPF JIT after these changes.

Thanks to Daniel and Alexei for their invaluable feedback and review.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

since v1:
 -- add tail call support
 -- fix MOD generation to not emit the same constant load several times
 -- flush icache over entire buffer properly
 -- do STACK_BIAS adjustment of FP once in prologue
 -- remove useless sanity checks
 -- generate patches with -M -C

since RFC:
 -- rework register allocation so that we don't have to emit move
    instructions to get the arguments into place for calls
 -- allow FP as source for 64-bit ALU move operations
 -- don't emit NOP instructions in prologue, instead do multiple
    passes so that all the branch offsets settle down
 -- remove unnecessary checks on imm64 loads that verifier does
 -- consistently use bpf2sparc[] instead of direct register references
