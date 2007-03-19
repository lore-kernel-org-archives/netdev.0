From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: Mon, 19 Mar 2007 12:25:12 -0600
Message-ID: <m1648xxf93.fsf@ebiederm.dsl.xmission.com>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, David Miller <davem@davemloft.net>,
	jeremy@goop.org, mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	zach@vmware.com, anthony@codemonkey.ws,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:55749 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933151AbXCSS1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 14:27:23 -0400
In-Reply-To: <1174272469.11680.23.camel@localhost.localdomain> (Rusty
	Russell's message of "Mon, 19 Mar 2007 13:47:49 +1100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell <rusty@rustcorp.com.au> writes:

> On Sun, 2007-03-18 at 13:08 +0100, Andi Kleen wrote:
>> > The idea is _NOT_ that you go look for references to the paravirt_ops
>> > members structure, that would be stupid and you wouldn't be able to
>> > use the most efficient addressing mode on a given cpu, you'd be
>> > patching up indirect calls and crap like that.  Just say no...
>> 
>> That wouldn't handle inlines though. At least some of the current
>> paravirtops like cli/sti are critical enough to require inlining.
>
> Well, we'd patch the inline over the call if we have room.
>
> Magic patching would be neat, but the downsides are that (1) we can't
> expand the patching room and (2) there's no way of attaching clobber
> info to the call site (doing register liveness analysis is not
> appealing).

True.  You can use all of the call clobbered registers.

> Now, this may not be fatal.  5 bytes is enough for all the native ops to
> be patched inline.   For lguest this covers popf and pushf, but not cli
> and sti (10 bytes): they'd have to be calls.
>
> As for clobber info, it turns out that almost all of the calls can
> clobber %eax, which is probably enough.  We just need to mark the
> handful of asm ones where this isn't true.

I guess if the code is larger than a function call I'm failing to see
the disadvantage in making it a direct function call.  Any modern
processor ought to be able to predict it perfectly, and processors
like the P4 may even optimize the call out of their L1 instruction
cache.

If what David is suggesting works, making all of these direct calls
looks easy and very maintainable.   At which point patching
instructions inline is quite possibly overkill.

Is it truly critical to inline any of these instructions?

Eric
