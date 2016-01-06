From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 06 Jan 2016 12:05:54 -0800
Message-ID: <87wprmean1.fsf@tassilo.jf.intel.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<hpa@zytor.com>, <x86@kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21780 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378AbcAFUGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 15:06:07 -0500
In-Reply-To: <1452019261-449449-1-git-send-email-tom@herbertland.com> (Tom
	Herbert's message of "Tue, 5 Jan 2016 10:41:01 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> writes:

> Also, we don't do anything special for alignment, unaligned
> accesses on x86 do not appear to be a performance issue.

This is not true on Atom CPUs.

Also on most CPUs there is still a larger penalty when crossing
cache lines.

> Verified correctness by testing arbitrary length buffer filled with
> random data. For each buffer I compared the computed checksum
> using the original algorithm for each possible alignment (0-7 bytes).
>
> Checksum performance:
>
> Isolating old and new implementation for some common cases:

You forgot to state the CPU. The results likely depend heavily
on the micro architecture.

The original C code was optimized for K8 FWIW.

Overall your assembler looks similar to the C code, except for the jump
table. Jump table has the disadvantage that it is much harder to branch
predict, with a large penalty if it's mispredicted.

I would expect it to be slower for cases where the length
changes frequently. Did you benchmark that case?

-Andi
