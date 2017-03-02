From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 02 Mar 2017 21:40:51 +0100
Message-ID: <58B88353.2010508@iogearbox.net>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com> <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, ast@fb.com
To: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46825 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751101AbdCBVbs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 16:31:48 -0500
In-Reply-To: <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2017 09:23 PM, Fengguang Wu wrote:
[...]
> I confirm that the below patch provided by Daniel fixes the above
> issues on mainline kernel, too. Where should this patch be sent to?

If nobody objects, I could send it to -net tree via Dave due to being
BPF related, but I don't mind sending it elsewhere too (f.e. Linus
directly?) in order to stop your bot from continuing to send such mails.

The issue seems only related to i386 and doesn't trigger each time with
Fengguang's kernel config and qemu image when I try to reproduce it.
set_memory_ro()/set_memory_rw() on i386 seems to work in general, but
when it's used/reproduced, from time to time (perhaps some corner-case?)
it looks like that memory area can have issues much later on after being
fed back to the allocator which then causes a GPF from random locations.
Gut feeling, it might be an issue in set_memory_*() that my commit
uncovered. Still looking into it, but mean-time I could just send the
below, sure.

Thanks,
Daniel

> It'd be very noisy if all these Oops hit the upcoming RC1 kernel.
>
> Daniel thinks there may be deeper problem in i386 set_memory_rw().
> However that could take much longer time to debug.
>
> Thanks,
> Fengguang
> ---
>
> Re: [bpf] 9d876e79df:  BUG: unable to handle kernel paging request at 653a8346
>
>> On Tue, Feb 28, 2017 at 04:39:36PM +0100, Daniel Borkmann wrote:
>
> I have a rough feeling what it is, but I didn't have cycles to work on
> it yet (due to travel, sorry about that). The issue is likely shut down
> by just doing:
>
> ---
> arch/x86/Kconfig |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
> --- linux.orig/arch/x86/Kconfig    2017-03-03 03:44:35.962022996 +0800
> +++ linux/arch/x86/Kconfig    2017-03-03 03:44:35.962022996 +0800
> @@ -54,7 +54,7 @@ config X86
>      select ARCH_HAS_KCOV            if X86_64
>      select ARCH_HAS_MMIO_FLUSH
>      select ARCH_HAS_PMEM_API        if X86_64
> -    select ARCH_HAS_SET_MEMORY
> +    select ARCH_HAS_SET_MEMORY        if X86_64
>      select ARCH_HAS_SG_CHAIN
>      select ARCH_HAS_STRICT_KERNEL_RWX
>      select ARCH_HAS_STRICT_MODULE_RWX
