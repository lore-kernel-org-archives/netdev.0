From: Nick Jones <nick.jones@network-box.com>
Subject: Re: [PATCH net-next v4] ipv6: Allocate unique metrics for icmp6
 packets to prevent tainting dst metrics
Date: Tue, 20 Mar 2012 13:48:01 +0800
Message-ID: <1332222481.25418.540.camel@nbnickhq4>
References: <4F64B203.40307@network-box.com>
	 <1332002201.19406.25.camel@edumazet-glaptop>
	 <4F64CD4B.4070203@network-box.com>
	 <20120319.180415.1274216814977167410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from erika.network-box.com ([202.52.42.180]:40792 "EHLO
	nbmailscanhq1.network-box.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932135Ab2CTFyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 01:54:22 -0400
In-Reply-To: <20120319.180415.1274216814977167410.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-19 at 18:04 -0400, David Miller wrote: 
> From: Nick Jones <nick.jones@network-box.com>
> Date: Sun, 18 Mar 2012 01:43:39 +0800
> 
> > +		return ERR_CAST(-ENOMEM);
> 
> Really, please, stop wasting my time.  There is no way your compiler
> didn't emit a warning for that garbage.
> 

This is really sloppy, I apologise.  I'll work on tightening up my
workflow for build testing, runtime testing and patch submission before
I bother you again.

> Furthermore, callers are only ready to handle NULL vs. non-NULL as
> return values from this function.  So this return value you are adding
> will result in crashes.

This one I did check.  icmp6_dst_alloc returns error encoded pointers
and all call sites test the return value with IS_ERR, I simply didn't
understand the correct formatting macro, nor check the build properly.
I think you got it mixed up with ip6_dst_alloc

The 'return NULL' at the bottom of the second fragment was a bug, but
this again exposes my newness to kernel patch submission workflow: that
bug was fixed recently and this patch wouldn't have applied, further
wasting your time... wonderful.

I'll let the merge window close to let things settle down for you before
bringing this fix up again.
