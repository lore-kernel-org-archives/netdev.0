From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a
 cond_resched()
Date: Thu, 15 Nov 2007 00:52:08 -0800 (PST)
Message-ID: <20071115.005208.60086049.davem@davemloft.net>
References: <473B69D5.2050805@cosmosbay.com>
	<p73r6isc6ev.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54817
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756478AbXKOIwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 03:52:09 -0500
In-Reply-To: <p73r6isc6ev.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 15 Nov 2007 08:30:16 +0100

> Eric Dumazet <dada1@cosmosbay.com> writes:
> >
> > Using a "if (need_resched())" test before calling "cond_resched();" is
> > necessary to avoid spending too much time doing the resched check.
> 
> The only difference between cond_resched() and if (need_resched())
> cond_resched() is one function call less and one might_sleep less. If
> the might_sleep or the function call are really problems (did you
> measure it? -- i doubt it somewhat) then it would be better to fix the
> generic code to either inline that or supply a __cond_resched()
> without might_sleep.
> 
> A cheaper change might have been to just limit the number of buckets
> scanned.

Fix up unmap_vmas() too if this is done as it does a similar
need_resched() check too.
