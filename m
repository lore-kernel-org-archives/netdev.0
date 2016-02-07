From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: e1000e er32(TIMINCA) value returned 0 Virtual Machiens
Date: Sun, 7 Feb 2016 23:04:03 +0100
Message-ID: <20160207220403.GA13888@localhost.localdomain>
References: <CAHC3ikmsH5KikrSMtCx+DWvnJyuhZ48JZGKK7MiYnLMV6wc=Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Elliott <tommygunsster@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35971 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbcBGWEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:04:09 -0500
Received: by mail-wm0-f41.google.com with SMTP id p63so90896020wmp.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:04:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHC3ikmsH5KikrSMtCx+DWvnJyuhZ48JZGKK7MiYnLMV6wc=Kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 07, 2016 at 10:28:48AM -0500, Thomas Elliott wrote:
> task: ffff88003e4b8000 ti: ffff88003e4c0000 task.ti: ffff88003e4c0000
> RIP: 0010:[<ffffffff8172817a>]  [<ffffffff8172817a>] 0xffffffff8172817a
> RSP: 0000:ffff88003e4c3cf0  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffff880038cdf640 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880038cdf628
> RBP: ffff880038cdf628 R08: 0000000000000032 R09: 0000000000000000
> R10: 00000007ffffffff R11: 00000000070f8406 R12: 142fe5b9982e5912
> R13: ffff880038cdcc38 R14: 0000000000000000 R15: 0000000000000000
> FS:  0000000000000000(0000) GS:ffff88003ea00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000000 CR3: 0000000001f74000 CR4: 00000000000006b0
> Stack:
>  ffffffff81071eca ffff880038cdc780 0000000000000000 0000000000000000
>  ffffffff8172ec3c 01a000002252a32c ffff880038cdc780 ffff880038cdcc38
>  0000000000008000 ffff880038cdcc38 0000000000000003 ffff880038cdc000
> Call Trace:
>  [<ffffffff81071eca>] ? 0xffffffff81071eca

Are you sure about the which funtion throws this bug?  KALLSYMS?

> A proposed fix is to check if TIMINCA is returned with 0, as division
> by 0 seems to be the reasoning for the panic altogether.

Divide by zero is indeed a bug, but the question is, why does this
happen?
 
> As I understand this isn't a "normal" situation for physical boards,
> it still seems a bit rought to always expect physical boards will
> NEVER return 0 for this situation.

That register is set to a non-zero value in e1000e_config_hwtstamp,
which is called from e1000_probe via e1000e_reset.  So it appears to
be initialized.

> All this does is check if the value of incvalue is 0 and return systim
> if it is.  This means you're not going to run into a situation and is
> just plain, in my opinion, better error checking.  A single line of
> code that allows VMs, and possibly future hardware that might present
> this issue, from panicking over something that is so simple a check.

This is only papering only the problem.  We need to know how TIMINCA
is getting cleared to zero.

Thanks,
Richard
