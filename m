From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] ebpf: bpf_map_*: fix linker error on avr32 and
 openrisc arch
Date: Fri, 6 Mar 2015 09:20:23 +0200
Message-ID: <CAJ3xEMgyiurkgaUwU7utcG+qdRD6k5SfS8Vsebf=fH_8-pYW0g@mail.gmail.com>
References: <dc0fc4f224a95f2a9813079229cb9cc0ac069d52.1425594286.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:41879 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbbCFHUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 02:20:24 -0500
Received: by oiav63 with SMTP id v63so16251876oia.8
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 23:20:23 -0800 (PST)
In-Reply-To: <dc0fc4f224a95f2a9813079229cb9cc0ac069d52.1425594286.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 6, 2015 at 12:27 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Fengguang reported, that on openrisc and avr32 architectures, we
> get the following linker errors on *_defconfig builds that have
> no bpf syscall support:
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


isn't that a 4.0-rc commit? if this is the case, this is for net, not net-next
