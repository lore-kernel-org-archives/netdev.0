From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH] tun: Fix unicast filter overflow
Date: Sun, 08 Feb 2009 18:43:57 -0700
Message-ID: <1234143837.20601.11.camel@2710p.home>
References: <20090207174404.16716.20574.stgit@kvm.aw>
	 <20090208.170605.01154488.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:38270 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934AbZBIBoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 20:44:06 -0500
In-Reply-To: <20090208.170605.01154488.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-02-08 at 17:06 -0800, David Miller wrote:
> From: Alex Williamson <alex.williamson@hp.com>
> Date: Sat, 07 Feb 2009 10:45:13 -0700
> 
> > Tap devices can make use of a small MAC filter set via the
> > TUNSETTXFILTER ioctl.  The filter has a set of exact matches
> > plus a hash for imperfect filtering of additional multicast
> > addresses.  The current code is unbalanced, adding unicast
> > addresses to the multicast hash, but only checking the hash
> > against multicast addresses.  This results in the filter
> > dropping unicast addresses that overflow the exact filter.
> > The fix is simply to disable the filter by leaving count set
> > to zero if we find non-multicast addresses after the exact
> > match table is filled.
> > 
> > Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> 
> Doesn't it make more sense to remove the multicast check
> in the filter check function?
> 
> With your change, the user gets absolutely no indication
> that filtering has been completely disabled simply because
> they put too many unicast addresses into the filter.  We
> just return zero, that's crazy.

Sure, that's another option, but we'd then need to figure out what to do
with TUN_FLT_ALLMULTI.  Unicast would almost needs it's own hash list if
we want to support an allmulti mode that's less than promiscuous.  The
return value of the ioctl is the number of exact filters, so the user
will know what happened.  Thanks,

Alex


