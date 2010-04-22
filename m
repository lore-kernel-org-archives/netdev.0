From: David Miller <davem@davemloft.net>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Thu, 22 Apr 2010 00:43:24 -0700 (PDT)
Message-ID: <20100422.004324.67422011.davem@davemloft.net>
References: <20100420174401.GB1334@midget.suse.cz>
	<20100421213429.GA2799@midget.suse.cz>
	<20100422023211.GA7109@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752429Ab0DVHnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:43:19 -0400
In-Reply-To: <20100422023211.GA7109@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Apr 2010 10:32:11 +0800

> Anyway, I think the root of the issue is the fact that NDISC is
> calling addrconf_dad_failure with no locking whatsoever.  The
> latter is not idempotent so some form of locking is needed.
> 
> This bug appears to have been around since the very start.
> 
> I'll dig deeper to see where we might be able to add some locks.

Thanks Herbert.
