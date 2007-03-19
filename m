From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Mon, 19 Mar 2007 13:47:49 +1100
Message-ID: <1174272469.11680.23.camel@localhost.localdomain>
References: <20070316.023331.59468179.davem@davemloft.net>
	 <45FB005D.9060809@goop.org>
	 <1174127638.8897.75.camel@localhost.localdomain>
	 <20070318.003309.71088169.davem@davemloft.net>
	 <20070318120814.GA45869@muc.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeremy@goop.org, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, zach@vmware.com, anthony@codemonkey.ws,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: Andi Kleen <ak@muc.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39541 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933741AbXCSCsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2007 22:48:19 -0400
In-Reply-To: <20070318120814.GA45869@muc.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-03-18 at 13:08 +0100, Andi Kleen wrote:
> > The idea is _NOT_ that you go look for references to the paravirt_ops
> > members structure, that would be stupid and you wouldn't be able to
> > use the most efficient addressing mode on a given cpu, you'd be
> > patching up indirect calls and crap like that.  Just say no...
> 
> That wouldn't handle inlines though. At least some of the current
> paravirtops like cli/sti are critical enough to require inlining.

Well, we'd patch the inline over the call if we have room.

Magic patching would be neat, but the downsides are that (1) we can't
expand the patching room and (2) there's no way of attaching clobber
info to the call site (doing register liveness analysis is not
appealing).

Now, this may not be fatal.  5 bytes is enough for all the native ops to
be patched inline.   For lguest this covers popf and pushf, but not cli
and sti (10 bytes): they'd have to be calls.

As for clobber info, it turns out that almost all of the calls can
clobber %eax, which is probably enough.  We just need to mark the
handful of asm ones where this isn't true.

Thoughts?
Rusty.

