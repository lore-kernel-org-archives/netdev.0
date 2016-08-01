From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] bpf: silence warnings when building kernel/bpf/core.c
 with W=1
Date: Mon, 1 Aug 2016 08:09:57 -0700
Message-ID: <20160801150955.GA99277@ast-mbp.thefacebook.com>
References: <23710.1470026010@turing-police.cc.vt.edu>
 <20160801044220.GA97382@ast-mbp.thefacebook.com>
 <28964.1470028723@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35799 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbcHAPX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 11:23:26 -0400
Content-Disposition: inline
In-Reply-To: <28964.1470028723@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 01, 2016 at 01:18:43AM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Sun, 31 Jul 2016 21:42:22 -0700, Alexei Starovoitov said:
> 
> > and at least 2 other such patches for other files...
> > Is there a single warning where -Woverride-init was useful?
> > May be worth disabling this warning for the whole build?
> 
> There's a few other cases that *aren't* the "define the array to zero
> and then build the entries from a list" form.
> 
> In particular, there's still 3 odd complaints:
> 
> drivers/ata/ahci.c:
> drivers/ata/ahci.h:393:16: warning: initialized field overwritten [-Woverride-in
> it]
>   .can_queue  = AHCI_MAX_CMDS - 1,
> 
> drivers/block/drbd/drbd_main.c:
> drivers/block/drbd/drbd_main.c:3767:22: warning: initialized field overwritten [
> -Woverride-init]
>    [P_RETRY_WRITE]  = "retry_write",
> 
> arch/x86/kernel/cpu/common.c:
> ./arch/x86/include/asm/page_64_types.h:22:21: warning: initialized field overwri
> tten [-Woverride-init]
>  #define DEBUG_STKSZ (PAGE_SIZE << DEBUG_STACK_ORDER)
> 
> The point of these patches is to make -Woverride-init *useful* - you'll never
> spot 3 warnings in a flood of over 9,000 understood-and-ignored warnings.
> 
> Get rid of the 9,000 understood-and-ignored warnings, and then things that
> probably *should* be looked at can be noticed.

I don't think it makes sense to play kernel whack-a-warning in a hope that
particular warning will find something useful.
Please show few cases where it actually found a real issue, otherwise
just disable it for all.
