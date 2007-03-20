From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 09:58:53 -0600
Message-ID: <m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
	<1174348905.11680.54.camel@localhost.localdomain>
	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Zachary Amsden <zach@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@muc.de>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:59257 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbXCTQBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 12:01:36 -0400
In-Reply-To: <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	(Linus Torvalds's message of "Tue, 20 Mar 2007 08:09:46 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Mon, 19 Mar 2007, Jeremy Fitzhardinge wrote:
>> Actually, it still does need a temp register.  The sequence for cli is:
>> 
>>     mov %fs:xen_vcpu, %eax
>>     movb $1,1(%eax)
>
> We should just do this natively. There's been several tests over the years 
> saying that it's much more efficient to do sti/cli as a simple store, and 
> handling the "oops, we got an interrupt while interrupts were disabled" as 
> a special case.
>
> I have this dim memory that ARM has done it that way for a long time 
> because it's so expensive to do a "real" cli/sti.
>
> And I think -rt does it for other reasons. It's just more flexible.

If that is the case.  In the normal kernel what would
the "the oops, we got an interrupt code do?"
I assume it would leave interrupts disabled when it returns?
Like we currently do with the delayed disable of normal interrupts?

I'm trying to understand the proposed semantics.

Looking at the above code snippet.  I guess it is about time to
merge our per_cpu and pda variables...

Eric
