From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: neighbour table ABI problem
Date: Wed, 21 May 2008 13:35:10 -0700 (PDT)
Message-ID: <20080521.133510.145260976.davem@davemloft.net>
References: <20080521163815.GA5028@sc.homeunix.net>
	<4834544A.4010706@trash.net>
	<20080521104019.22f9c712@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, tgraf@suug.ch, Stephane_Chazelas@yahoo.fr,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758492AbYEUUfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 16:35:15 -0400
In-Reply-To: <20080521104019.22f9c712@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 21 May 2008 10:40:19 -0700

> The neighbor table time of last use information is returned in the incorrect
> unit. Kernel to user space ABI's need to use USER_HZ (or milliseconds), otherwise
> the application has to try and discover the real system HZ value which is problematic.
> Linux has standardized on keeping USER_HZ consistent (100hz) even when kernel is
> running internally at some other value.
> 
> This change is small, but it breaks the ABI for older version of iproute2 utilities.
> But these utilities are already broken since they are looking at the psched_hz values
> which are completely different. So let's just go ahead and fix both kernel and user
> space. Older utilities will just print wrong values.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

In at least one sense the kernel has been providing a consistent
value :-)

I don't know what to do here, it's different from the other patch
you posted today in that I can't see any easy way to not change
behavior for old stuff.

Can we add a new attribute or something like that?
