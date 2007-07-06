From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Thu, 5 Jul 2007 17:00:51 -0700
Message-ID: <20070705170051.37ff2ab8@freepuppy.localdomain.hemminger.net>
References: <20070705231412.021359760@linux-foundation.org>
	<20070705231615.451797310@linux-foundation.org>
	<20070705.164308.01771618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36444 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760886AbXGFABd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 20:01:33 -0400
In-Reply-To: <20070705.164308.01771618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 05 Jul 2007 16:43:08 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Thu, 05 Jul 2007 16:14:14 -0700
> 
> > The scatterlist only needs 16 bits for length/offset because
> > PAGE_SIZE is 4K
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Unfortunately I don't think this can be done, even on i386.
> 
> It is legal to use order!=0 pages and multi-page areas in a single
> scatterlist entry.
> 

Okay, but then using SG lists makes skbuff's much bigger.
    
	fraglist	scatterlist		   per skbuff
32 bit	8		20		+12 * 18 = +216!
64 bit	16		32		+16 * 18 = +288

So never mind...

I'll do a fraglist to scatter list set of routines, but not sure
if it's worth it.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
