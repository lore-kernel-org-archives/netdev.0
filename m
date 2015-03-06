From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] ebpf: bpf_map_*: fix linker error on avr32 and
 openrisc arch
Date: Thu, 05 Mar 2015 18:35:43 -0800
Message-ID: <54F9127F.8090501@plumgrid.com>
References: <dc0fc4f224a95f2a9813079229cb9cc0ac069d52.1425594286.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:34036 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbbCFCfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 21:35:46 -0500
Received: by qcvp6 with SMTP id p6so3820517qcv.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 18:35:46 -0800 (PST)
In-Reply-To: <dc0fc4f224a95f2a9813079229cb9cc0ac069d52.1425594286.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/15 2:27 PM, Daniel Borkmann wrote:
> Fengguang reported, that on openrisc and avr32 architectures, we
> get the following linker errors on *_defconfig builds that have
> no bpf syscall support:
>
>    net/built-in.o:(.rodata+0x1cd0): undefined reference to `bpf_map_lookup_elem_proto'
>    net/built-in.o:(.rodata+0x1cd4): undefined reference to `bpf_map_update_elem_proto'
>    net/built-in.o:(.rodata+0x1cd8): undefined reference to `bpf_map_delete_elem_proto'
>
> Fix it up by providing built-in weak definitions of the symbols,
> so they can be overridden when the syscall is enabled. I think
> the issue might be that gcc is not able to optimize all that away.
> This patch fixes the linker errors for me, tested with Fengguang's
> make.cross [1] script.
>
>    [1] https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Fixes: d4052c4aea0c ("ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

thanks :)
