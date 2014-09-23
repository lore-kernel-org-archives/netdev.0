From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: bpf: arm: make hole-faulting more
 robust
Date: Tue, 23 Sep 2014 12:40:48 -0400 (EDT)
Message-ID: <20140923.124048.2006238331601169260.davem@davemloft.net>
References: <1411131417-23667-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux@arm.linux.org.uk, catalin.marinas@arm.com,
	will.deacon@arm.com, mgherzan@gmail.com, ast@plumgrid.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822AbaIWQkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:40:51 -0400
In-Reply-To: <1411131417-23667-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 19 Sep 2014 14:56:57 +0200

> Will Deacon pointed out, that the currently used opcode for filling holes,
> that is 0xe7ffffff, seems not robust enough ...
 ...
> ... which is a bit fragile. The ARM specification defines some *permanently*
> guaranteed undefined instruction (UDF) space, for example for ARM in ARMv7-AR,
> section A5.4 and for Thumb in ARMv7-M, section A5.2.6.
> 
> Similarly, ptrace, kprobes, kgdb, bug and uprobes make use of such instruction
> as well to trap. Given mentioned section from the specification, we can find
> such a universe as (where 'x' denotes 'don't care'):
> 
>   ARM:    xxxx 0111 1111 xxxx xxxx xxxx 1111 xxxx
>   Thumb:  1101 1110 xxxx xxxx
> 
> We therefore should use a more robust opcode that fits both. Russell King
> suggested that we can even reuse a single 32-bit word, that is, 0xe7fddef1
> which will fault if executed in ARM *or* Thumb mode as done in f928d4f2a86f
> ("ARM: poison the vectors page"). That will still hold our requirements:
 ...
> So on ARM 0xe7fddef1 conforms to the above UDF pattern, and the low 16 bit
> likewise correspond to UDF in Thumb case. The 0xe7fd part is an unconditional
> branch back to the UDF instruction.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
