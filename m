From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer descriptor ownership.
Date: Sat, 5 May 2007 02:41:20 +0200
Message-ID: <319ad63a0d38335a6b0c221e8f3c26b0@kernel.crashing.org>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net> <F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org> <4638F0C4.2000406@freescale.com> <FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org> <4638F734.2040809@freescale.com> <20070504221309.GR6193@austin.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-03.arcor-online.net ([151.189.21.43]:53329 "EHLO
	mail-in-03.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161609AbXEEAlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 20:41:44 -0400
In-Reply-To: <20070504221309.GR6193@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Well, Segher doesn't want me to use iobarrier (because it's not I/O).
>> Andy doesn't want me to use wmb() (because it's sync).  I don't think
>> something like gfar_wmb() would be appropriate.  So the remaining
>> options are either eieio(),
>
> ? Just curious... the original intent of eieio was to order I/O,
> such as MMIO; it has no effect on memory that isn't marked
> cache-inhibited or write-trhough or guarded. Has this changed?

eieio orders all accesses to address space that is WIMG=1xxx
or WIMG=x1x1; separately, it orders stores to address space
that is WIMG=001x.

> I guess I haven't kept up with the times ... is eieio now
> being used to provide some other kind of barrier?

Nothing changed.

> Is eieio providing some sort of SMP synchronization side-effect?

It orders stores to "well-behaved" memory yes.

> Point being: if Segher doesn't let you "use iobarrier (because
> it's not I/O)", then I don't understand why eieio would work (since
> that's for io only).

iobarrier() is a kernel-level primitive, meant for ordering
I/O only, as its name indicates.  eieio is a CPU insn that
orders stores to main memory (amongst other things), not that
its name would tell you.


Segher

