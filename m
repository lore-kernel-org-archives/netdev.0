From: David Miller <davem@davemloft.net>
Subject: Re: sendmmsg: put_user vs __put_user
Date: Thu, 05 Apr 2012 21:01:13 -0400 (EDT)
Message-ID: <20120405.210113.1089032911004787990.davem@davemloft.net>
References: <CAOPLpQf2bmj+i_zYtsS8JNzTDuBxCO5ByNRRqwv0kxaDBFdezg@mail.gmail.com>
	<20120330.205120.2221145622131588797.davem@davemloft.net>
	<4F7E3561.8000803@mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drepper@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: luto@mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788Ab2DFBBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 21:01:17 -0400
In-Reply-To: <4F7E3561.8000803@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@mit.edu>
Date: Thu, 05 Apr 2012 17:14:25 -0700

> On 03/30/2012 05:51 PM, David Miller wrote:
>> From: Ulrich Drepper <drepper@gmail.com>
>> Date: Fri, 30 Mar 2012 09:36:11 -0400
>> 
>>> Shouldn't the compat code in the sendmmsg implementation use the same
>>> code as the normal code?  In which case you probably want something
>>> like this:
>> 
>> Compat processes are not able to generate virtual addresses anywhere
>> near the range where the kernel resides, so the address range
>> verification done by put_user() is completely superfluous and
>> therefore not necessary.  The normal exception handling done by the
>> access is completely sufficient.
> 
> I disagree.  The following exploit causes a bogus page fault to a kernel
> address.  I think this isn't exploitable right now on x86-64 because the
> page fault handler fixes it up, but I wouldn't be surprised if this
> crashes or at least warns on some architecture.  (Actually trashing
> kernel memory is probably impossible with this on x86-64 chips because
> this can only overrun user space by four bytes, and there's a giant gap
> of impossible addresses above user space in x86-64.

I can guarentee this doesn't do anything on sparc64 either because
userspace is completely segregated from kernel space in a way that
every single foo_user() call cannot access kernel space no matter
what address it can trick into being passed there.

I still really don't see an issue with this, sorry.
