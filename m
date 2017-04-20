From: David Miller <davem@davemloft.net>
Subject: more on FP operations
Date: Thu, 20 Apr 2017 14:06:17 -0400 (EDT)
Message-ID: <20170420.140617.91794616324352770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: borkmann@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46288 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970135AbdDTSGT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 14:06:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm running test_verifier for testing, and I notice in my JIT that a
32-bit move from the frame pointer (BPF_REG_10) ends up in the JIT.

It is from this test:

		"unpriv: partial copy of pointer",
		.insns = {
			BPF_MOV32_REG(BPF_REG_1, BPF_REG_10),
			BPF_MOV64_IMM(BPF_REG_0, 0),
			BPF_EXIT_INSN(),
		},
		.errstr_unpriv = "R10 partial copy",
		.result_unpriv = REJECT,
		.result = ACCEPT,

It seems to suggest that privileged code is allowed to do this, but I
can't think of a legitimate usage.

I really want to be able to JIT anything the verifier accepts, but I
have a hard time justifying adding 32-bit FP register move support,
adjusting for the stack bias, etc.

Thanks.
