From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Wed, 14 Mar 2007 21:54:23 -0700 (PDT)
Message-ID: <20070314.215423.59468080.davem@davemloft.net>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.509184287@linux-foundation.org>
	<20070315021840.GG1246@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43040
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965149AbXCOEyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 00:54:25 -0400
In-Reply-To: <20070315021840.GG1246@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Wed, 14 Mar 2007 22:18:40 -0400

> On Mon, Mar 12, 2007 at 02:08:18PM -0700, Stephen Hemminger wrote:
> > For Eric, mark packet type and network device watermarks
> > as read mostly.
> 
> The following x86-64 bits might be intersting, as they allow you to 
> completely eliminate the memory access for run time defined constants.  
> Note that read_always writes are non-atomic, so some other form of 
> protection is necessary for readers (and rcu won't cut it).  That can be 
> fixed somewhat by specifying the alignment for the mov instruction to 
> ensure writes are atomic, but for many uses that is overkill.  This kind 
> of change can make the biggest difference for high-latency cases, like L1 
> cache misses on the Prescott P4.  I've not benched it on a P4 of late, 
> though.

That's a really cool idea.

I think for this kind of stuff, however, we should just use ELF
relocations to handle this.  Don't resolve the symbols, record
references to them, resolve them to 0 in the image link, and make the
set_foo() routine walk the relocations and fill them out with the new
value.

We already have to have code to do this for modules.

Sparc32 already does something like this with it's btfixup mechanism,
it's the same kind of idea.
