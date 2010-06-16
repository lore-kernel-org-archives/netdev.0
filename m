From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Proposed linux kernel changes : scaling  tcp/ip stack
Date: Wed, 16 Jun 2010 11:10:07 +0200
Message-ID: <87fx0nwdg0.fsf@basil.nowhere.org>
References: <FDFFEFAB-A741-4232-821E-17BFAE5CAFAC@earthlink.net>
	<1275556440.2456.19.camel@edumazet-laptop>
	<97746864-ED54-4A12-AFE7-752AA6E41CDD@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51329 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931Ab0FPJKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 05:10:12 -0400
In-Reply-To: <97746864-ED54-4A12-AFE7-752AA6E41CDD@earthlink.net> (Mitchell Erblich's message of "Tue\, 15 Jun 2010 20\:11\:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mitchell Erblich <erblichs@earthlink.net> writes:
>
> Summary: Don't use last free pages for TCP ACKs with GFP_ATOMIC for our
> sk buf allocs. 1 line change in tcp_output.c with a new gfp.h arg, and a change
> in the generic kernel. TBD.
>
> This change should have no effect with normal available kernel mem allocs.
>
> Assuming memory pressure ( WAITING for clean memory) we should be allocating
> our last pages for input skbufs and not for xmit allocs.

How about you instrument a kernel and measure if this really happens
frequently under reasonable loads?  That is you can probably
use the existing dropped page counters in netstat 
Stephen added some time ago.

Since soft irqs cannot really wait exhausted GFP_ATOMIC would normally
lead to dropped packets. FWIW I am not aware of any serious dropped
packets problem on normal loads.

Running a kernel with nearly zero free memory is dangerous anyways
-- pretty much any kernel service can fail arbitarily --
if this happened frequently I suspect we would need generic
VM solution for it.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
