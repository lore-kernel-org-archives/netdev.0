From: Patrick McHardy <kaber@trash.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
 to -mm tree
Date: Mon, 09 Jul 2007 18:54:05 +0200
Message-ID: <4692682D.5030705@trash.net>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org>	 <1183642800.3789.11.camel@ranko-fc2.spidernet.net>	 <20070705142135.GG4759@ff.dom.local>	 <1183646029.4069.11.camel@ranko-fc2.spidernet.net>	 <1183651165.4069.26.camel@ranko-fc2.spidernet.net>	 <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local>	 <20070706064523.GA2144@ff.dom.local>	 <1183727654.6389.3.camel@ranko-fc2.spidernet.net>	 <468E4FD9.4060702@trash.net>	 <1183733732.6389.26.camel@ranko-fc2.spidernet.net>	 <1183794918.30237.69.camel@localhost.localdomain>	 <Pine.LNX.4.64.0707071704370.1808@x2>	 <1183984861.18656.21.camel@ranko-fc2.spidernet.net>	 <46923DA8.9010208@trash.net> <1183999420.18656.54.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34077 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbXGIQyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 12:54:24 -0400
In-Reply-To: <1183999420.18656.54.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ranko Zivojnovic wrote:
> On Mon, 2007-07-09 at 15:52 +0200, Patrick McHardy wrote:
> 
>>You could also use synchronize_rcu(), estimator destruction is
>>not particulary performance critical.
> 
> 
> I've tried synchronize_rcu(), but it went kaboom with the below, thus
> call_rcu() must stay:
> 
> ---cut---
> BUG: sleeping function called from invalid context at kernel/sched.c:3928
> in_atomic():1, irqs_disabled():0


Right, I forgot that we're holding some locks.

> [...]
> All the changes above now included in the attached patch. I've clean
> compiled it with 2.6.22 and now testing this version.


Looks good. Please resend with a Signed-off-by: line once you're done
testing so Dave can apply it (ideally with a new subject so it doesn't
get missed).

