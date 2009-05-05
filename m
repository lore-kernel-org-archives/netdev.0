From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 02:50:08 +0300
Message-ID: <20090505235008.GA17690@francoudi.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <4A0069F3.5030607@cosmosbay.com> <20090505174135.GA29716@francoudi.com> <4A008A72.6030607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:3566 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbZEEXuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 19:50:11 -0400
Content-Disposition: inline
In-Reply-To: <4A008A72.6030607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 05, 2009 at 08:50:26PM +0200, Eric Dumazet wrote:

> > I have tried with IRQs bound to one CPU per NIC. Same result.
> 
> Did you check "grep eth /proc/interrupts" that your affinities setup 
> were indeed taken into account ?
> 
> You should use same CPU for eth0 and eth2 (bond0),
> 
> and another CPU for eth1 and eth3 (bond1)

Ok, the best result is when assign all IRQs to the same CPU. Zero drops.

When I bind slaves of bond interfaces to the same CPU, I start to get 
some drops, but much less than before. I didn't play with combinations.

My problem is, after applying your accounting patch below, one of my 
HTB servers reports only 30-40% CPU idle on one of the cores. That won't 
take me for very long, load balancing across cores is needed.

Is there any way at least to balance individual NICs on per core basis?

-- 
Best Regards
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel, Cyprus - www.prime-tel.com
