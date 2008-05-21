From: David Miller <davem@davemloft.net>
Subject: Re: route metrics in jiffies??
Date: Wed, 21 May 2008 13:31:54 -0700 (PDT)
Message-ID: <20080521.133154.173559889.davem@davemloft.net>
References: <20080521163815.GA5028@sc.homeunix.net>
	<20080521101053.27db3495@extreme>
	<20080521114354.31c6807c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephane_Chazelas@yahoo.fr, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35590
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S937193AbYEUUb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 16:31:58 -0400
In-Reply-To: <20080521114354.31c6807c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 21 May 2008 11:43:54 -0700

> There is an even bigger mess up.  The API for route metrics has several
> values encoded in jiffies.  This is a problem because there is no good
> way to find the internal kernel value of HZ. So all kernel/user ABI's
> are supposed to use an absolute value (like milliseconds) or clock_t
> which user USER_HZ.
> 
> The problem is that these values are now hardcoded into people's systems
> so anyone using the 'ip route' options: rttvar, rtomin, or rtt are broken.
> They might be lucky now (but I doubt it).
> 
> I propose doing the right thing and fixing kernel and iproute to always
> use milliseconds for these values. To maintain compatibility, the new metric
> values will be renumbered.  So old kernels don't misinterpret the new values.

That is one way to solve the problem.  But we could be adding
surprises on a source level for people with this approach.

Just use new names and leave the old ones alone, with a _MS or similar
postfix to them.

This is how we've handled this kind of situation in the past.
