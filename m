From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: filter: BPF 'JIT' compiler for PPC64
Date: Thu, 21 Jul 2011 12:47:57 -0700 (PDT)
Message-ID: <20110721.124757.1998243180954846915.davem@davemloft.net>
References: <4E23E5C3.1070209@ozlabs.org>
	<4E24E867.9050909@ozlabs.org>
	<4E278604.5080605@ozlabs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: matt@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab1GUTuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 15:50:05 -0400
In-Reply-To: <4E278604.5080605@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Evans <matt@ozlabs.org>
Date: Thu, 21 Jul 2011 11:51:00 +1000

> An implementation of a code generator for BPF programs to speed up packet
> filtering on PPC64, inspired by Eric Dumazet's x86-64 version.
> 
> Filter code is generated as an ABI-compliant function in module_alloc()'d mem
> with stackframe & prologue/epilogue generated if required (simple filters don't
> need anything more than an li/blr).  The filter's local variables, M[], live in
> registers.  Supports all BPF opcodes, although "complicated" loads from negative
> packet offsets (e.g. SKF_LL_OFF) are not yet supported.
> 
> There are a couple of further optimisations left for future work; many-pass
> assembly with branch-reach reduction and a register allocator to push M[]
> variables into volatile registers would improve the code quality further.
> 
> This currently supports big-endian 64-bit PowerPC only (but is fairly simple
> to port to PPC32 or LE!).
> 
> Enabled in the same way as x86-64:
> 
> 	echo 1 > /proc/sys/net/core/bpf_jit_enable
> 
> Or, enabled with extra debug output:
> 
> 	echo 2 > /proc/sys/net/core/bpf_jit_enable
> 
> Signed-off-by: Matt Evans <matt@ozlabs.org>

Applied.
