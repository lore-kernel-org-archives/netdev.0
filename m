From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] bridge: remove !IFF_UP restriction when deleting
 bridge from ioctl
Date: Fri, 04 Apr 2014 11:08:00 -0400 (EDT)
Message-ID: <20140404.110800.1665495271585798396.davem@davemloft.net>
References: <1396623382.15118.6.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbaDDPGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 11:06:24 -0400
In-Reply-To: <1396623382.15118.6.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Fri, 04 Apr 2014 09:56:22 -0500

> netlink doesn't care about IFF_UP when deleting a bridge, so "ip link
> del br0" works just fine.  The ioctl does care, which means that brctl
> complains "bridge br0 still up; can't delete it".  Make things
> consistent by always allowing bridge deletion even if the bridge is up.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
> Question: does anyone consider the ioctl behavior API?  Can we change it
> even though it's been this way forever?  It means that bridges that
> previously would not have been deleted by brctl will now be deleted.
> But anyone using /sbin/ip could already delete them.

Unfortunately I think we're stuck with the existing behavior.

And since, as you say, iproute2 always does the removal when
the device is up, the behavior you desire is available.
