From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] test_bpf: indicate whether bpf prog got jited
 in test suite
Date: Thu, 30 Apr 2015 16:41:16 -0400 (EDT)
Message-ID: <20150430.164116.1218828988425937462.davem@davemloft.net>
References: <c031528c3effbdb3a3a566b0a8d6f48f3e4ad3be.1430403176.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nschichan@freebox.fr, ast@plumgrid.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbbD3UlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 16:41:18 -0400
In-Reply-To: <c031528c3effbdb3a3a566b0a8d6f48f3e4ad3be.1430403176.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 30 Apr 2015 16:17:27 +0200

> I think this is useful to verify whether a filter could be JITed or
> not in case of bpf_prog_enable >= 1, which otherwise the test suite
> doesn't tell besides taking a good peek at the performance numbers.
> 
> Nicolas Schichan reported a bug in the ARM JIT compiler that rejected
> and waved the filter to the interpreter although it shouldn't have.
> Nevertheless, the test passes as expected, but such information is
> not visible.
> 
> It's i.e. useful for the remaining classic JITs, but also for
> implementing remaining opcodes that are not yet present in eBPF JITs
> (e.g. ARM64 waves some of them to the interpreter). This minor patch
> allows to grep through dmesg to find those accordingly, but also
> provides a total summary, i.e.: [<X>/53 JIT'ed]
> 
>   # echo 1 > /proc/sys/net/core/bpf_jit_enable
>   # insmod lib/test_bpf.ko
>   # dmesg | grep "jited:0"
> 
> dmesg example on the ARM issue with JIT rejection:
> 
> [...]
> [   67.925387] test_bpf: #2 ADD_SUB_MUL_K jited:1 24 PASS
> [   67.930889] test_bpf: #3 DIV_MOD_KX jited:0 794 PASS
> [   67.943940] test_bpf: #4 AND_OR_LSH_K jited:1 20 20 PASS
> [...]
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
