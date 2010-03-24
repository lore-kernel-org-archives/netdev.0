From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on ia64
Date: Wed, 24 Mar 2010 23:47:24 +0100
Message-ID: <m2vdcl5ocj.fsf@igel.home>
References: <12c511ca1003181112t6098eeafm30e384e755a42185@mail.gmail.com>
	<alpine.LSU.2.01.1003192310450.10055@obet.zrqbmnf.qr>
	<20100324.102759.107122703.davem@davemloft.net>
	<alpine.LSU.2.01.1003242059230.4028@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tony.luck@intel.com,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:44381 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab0CXWr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 18:47:28 -0400
In-Reply-To: <alpine.LSU.2.01.1003242059230.4028@obet.zrqbmnf.qr> (Jan
	Engelhardt's message of "Wed, 24 Mar 2010 22:26:24 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt <jengelh@medozas.de> writes:

> Using a temporary and memcpying it off would normally fix this,
> as in the patch below. During testing however, I still get
> unaligned messages even with the patch - and I would not know
> what causes this.

The memcpy will not fix the alignment issue because the copy operation
is fully equivalent to a direct assignment, and the compiler can still
take advantage of the known alignment of the types.  You have to
explicitly tell the compiler about the reduced alignment guarantee.

> In fact, adding a printks magically fixes it. (Bug in gcc-4.4-sparc
> compiler?)
>
>  	memcpy(v, &a, sizeof(a));
> +       printk(KERN_INFO "v=%p a=%p\n", v, &a);

Presumably the extended lifetime of the variables caused the compiler to
use a different expansion for memcpy which is less dependent on
alignment.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
