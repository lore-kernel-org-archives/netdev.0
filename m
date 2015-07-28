From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] ebpf, x86: fix general protection fault when tail
 call is invoked
Date: Tue, 28 Jul 2015 10:02:08 -0700
Message-ID: <55B7B590.8030600@plumgrid.com>
References: <23a2630be3c3d41932b9df134f06b9b44671b55e.1438088105.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35704 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbbG1RCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 13:02:11 -0400
Received: by pabkd10 with SMTP id kd10so72790852pab.2
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 10:02:11 -0700 (PDT)
In-Reply-To: <23a2630be3c3d41932b9df134f06b9b44671b55e.1438088105.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/15 6:26 AM, Daniel Borkmann wrote:
> After patch, disassembly:
>
>    [...]
>    9e:   lea    0x80(%rsi,%rdx,8),%rax   <--- CONFIG_LOCKDEP/CONFIG_LOCK_STAT
>          48 8d 84 d6 80 00 00 00
>    a6:   mov    (%rax),%rax
>          48 8b 00
>    [...]
>
>    [...]
>    9e:   lea    0x50(%rsi,%rdx,8),%rax   <--- No CONFIG_LOCKDEP
>          48 8d 84 d6 50 00 00 00
>    a6:   mov    (%rax),%rax
>          48 8b 00
>    [...]
>
> Fixes: b52f00e6a715 ("x86: bpf_jit: implement bpf_tail_call() helper")
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Thanks for fixing it.
Most of my development is actually with LOCKDEP on, but I don't ever
turn LOCK_STAT on, so sadly missed this 48 byte increase of 80 byte
structure :(

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
