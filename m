From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 19:34:46 -0700 (PDT)
Message-ID: <20120821.193446.1534561579811962053.davem@davemloft.net>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	<503437D4.8090706@zytor.com>
	<1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	x86@kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab2HVCes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 22:34:48 -0400
In-Reply-To: <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 22 Aug 2012 03:04:11 +0100

> On Tue, 2012-08-21 at 18:37 -0700, H. Peter Anvin wrote:
>> On 08/21/2012 06:23 PM, Ben Hutchings wrote:
>> > Define reado(), writeo() and their raw counterparts using SSE.
>> > 
>> > Based on work by Stuart Hodgson <smhodgson@solarflare.com>.
>> 
>> It would be vastly better if we explicitly controlled this with
>> kernel_fpu_begin()/kernel_fpu_end() rather than hiding it in primitives
>> than might tempt the user to do very much the wrong thing.
>> 
>> Also, it needs to be extremely clear to the user that these operations
>> use the FPU, and all the requirements there need to be met, including
>> not using them at interrupt time.
> 
> Well we can sometimes use the FPU state at IRQ time, can't we
> (irq_fpu_usable())?   So we might need, say, try_reado() and
> try_writeo() with callers expected to fall back to alternatives.  (Which
> they must have anyway for any architecture that doesn't support this.)

I really hope we eventually get rid of this rediculous restriction the
x86 code has.

It really needs a proper stack of FPU state saves like sparc64 has.

Half of the code and complexity in arch/x86/crypto/ would just
disappear, because most of it has to do with handling this obtuse
FPU usage restriction which shouldn't even be an issue in the first
place.

I continually see more and more code that has to check this
irq_fpu_usable() thing, and have ugly fallback code, and therefore is
a sign that this really needs to be fixed properly.
