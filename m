From: David Miller <davem@davemloft.net>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 12:08:54 -0700 (PDT)
Message-ID: <20070319.120854.30182994.davem@davemloft.net>
References: <20070318193030.GB71548@muc.de>
	<45FDCF52.4000805@goop.org>
	<200703191157.29780.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, jbeulich@novell.com,
	jeremy@goop.org, ak@muc.de, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chrisw@sous-sol.org, virtualization@lists.osdl.org,
	anthony@codemonkey.ws, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, mingo@elte.hu
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751755AbXCSTIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 15:08:54 -0400
In-Reply-To: <200703191157.29780.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Mon, 19 Mar 2007 11:57:28 +0100

> On Monday 19 March 2007 00:46, Jeremy Fitzhardinge wrote:
> > Andi Kleen wrote:
> > For example, say we wanted to put a general call for sti into entry.S,
> > where its expected it won't touch any registers.  In that case, we'd
> > have a sequence like:
> >
> >     push %eax
> >     push %ecx
> >     push %edx
> >     call paravirt_cli
> >     pop %edx
> >     pop %ecx
> >     pop %eax
> 
> This cannot right now be expressed as inline assembly in the unwinder at all 
> because there is no way to inject the push/pops into the compiler generated
> ehframe tables.
> 
> [BTW I plan to resubmit the unwinder with some changes]

It's inability to handle sequences like the above sounds to me like
a very good argument to _not_ merge the unwinder back into the tree.

To me, that unwinder is nothing but trouble, it severly limits what
cases you can use special calling conventions via inline asm (and we
have done that on several occaisions) and even ignoring that the
unwinder only works half the time.

Please don't subject us to another couple months of hair-pulling only
to have Linus yank the thing out again, there are certainly more
useful things to spend time on :-)
