From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: zillions of lockdep whinges in
 include/net/sock.h:1408
Date: Sun, 24 Apr 2016 14:00:17 -0700
Message-ID: <1461531617.5535.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <43037.1461229555@turing-police.cc.vt.edu>
	 <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5718DA71.7050902@stressinduktion.org>
	 <20160424.143833.2292980084570149367.davem@davemloft.net>
	 <571D14F8.6070306@stressinduktion.org>
	 <1461527202.5535.1.camel@edumazet-glaptop3.roam.corp.google.com>
	 <176911.1461527778@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33257 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbcDXVAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 17:00:19 -0400
In-Reply-To: <176911.1461527778@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-04-24 at 15:56 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Sun, 24 Apr 2016 12:46:42 -0700, Eric Dumazet said:
> 
> > >>> +	return !debug_locks ||
> > >>> +	       lockdep_is_held(&sk->sk_lock) ||
> 
> > Issue here is that once lockdep detected a problem (not necessarily in
> > net/ tree btw), your helper always 'detect' a problem, since lockdep
> > automatically disables itself.
> 
> "D'Oh!" -- H. Simpson
> 
> I thought this patch looked suspect, but couldn't put my finger on it. The
> reason why I got like 41,000 of them is because I built a kernel that has
> lockdep enabled, but I have an out-of-tree module that doesn't init something,
> so I get this:
> 
> [   48.898156] INFO: trying to register non-static key.
> [   48.898157] the code is fine but needs lockdep annotation.
> [   48.898157] turning off the locking correctness validator.
> 
> After which point, even with this patch, every time through it's still going to
> explode.

Which patch are you talking about ?
