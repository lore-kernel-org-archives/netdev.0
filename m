From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ebpf: bpf_map_*: fix linker error on avr32
 and openrisc arch
Date: Fri, 06 Mar 2015 01:05:53 -0500 (EST)
Message-ID: <20150306.010553.1266565423558104748.davem@davemloft.net>
References: <dc0fc4f224a95f2a9813079229cb9cc0ac069d52.1425594286.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837AbbCFGFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 01:05:55 -0500
In-Reply-To: <dc0fc4f224a95f2a9813079229cb9cc0ac069d52.1425594286.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  5 Mar 2015 23:27:51 +0100

> Fengguang reported, that on openrisc and avr32 architectures, we
> get the following linker errors on *_defconfig builds that have
> no bpf syscall support:
> 
>   net/built-in.o:(.rodata+0x1cd0): undefined reference to `bpf_map_lookup_elem_proto'
>   net/built-in.o:(.rodata+0x1cd4): undefined reference to `bpf_map_update_elem_proto'
>   net/built-in.o:(.rodata+0x1cd8): undefined reference to `bpf_map_delete_elem_proto'
> 
> Fix it up by providing built-in weak definitions of the symbols,
> so they can be overridden when the syscall is enabled. I think
> the issue might be that gcc is not able to optimize all that away.
> This patch fixes the linker errors for me, tested with Fengguang's
> make.cross [1] script.
> 
>   [1] https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Fixes: d4052c4aea0c ("ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
