From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Tue, 21 Feb 2012 07:19:22 +0100
Message-ID: <20120221061922.GE31660@secunet.com>
References: <20120210075106.GL23142@secunet.com>
 <20120210.031211.2297215055759518521.davem@davemloft.net>
 <20120210084424.GM23142@secunet.com>
 <20120210.132557.396788563105190450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32930 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808Ab2BUGT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 01:19:29 -0500
Content-Disposition: inline
In-Reply-To: <20120210.132557.396788563105190450.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2012 at 01:25:57PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Fri, 10 Feb 2012 09:44:25 +0100
> 
> > On Fri, Feb 10, 2012 at 03:12:11AM -0500, David Miller wrote:
> >> 
> >> So since this happens, you don't need to check the inetpeer at every
> >> metric access.  The fact that all routing cache entries get recreated
> >> will do it for you.
> > 
> > So if rt_init_metrics() is not the right place to check for genid
> > changes, where would you suggest to do it?
> 
> It is the right place, and since it will happen there for every routing
> cache entry we use after a flush, the inetpeer issues will be taken
> care of by it.  Therefore you don't need to check anything at metrics
> access time.

Ok, apparently I looked at the wrong place. The only checks at metrics
access that might be superfluous are the inet_metrics_new() checks in
ipv4_metrics() and ipv6_metrics(). If these are the checks you mean,
I'd remove them and resend the patchset.
