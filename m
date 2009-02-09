From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: Fix unicast filter overflow
Date: Sun, 08 Feb 2009 17:06:05 -0800 (PST)
Message-ID: <20090208.170605.01154488.davem@davemloft.net>
References: <20090207174404.16716.20574.stgit@kvm.aw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: alex.williamson@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36145
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751623AbZBIBGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 20:06:12 -0500
In-Reply-To: <20090207174404.16716.20574.stgit@kvm.aw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@hp.com>
Date: Sat, 07 Feb 2009 10:45:13 -0700

> Tap devices can make use of a small MAC filter set via the
> TUNSETTXFILTER ioctl.  The filter has a set of exact matches
> plus a hash for imperfect filtering of additional multicast
> addresses.  The current code is unbalanced, adding unicast
> addresses to the multicast hash, but only checking the hash
> against multicast addresses.  This results in the filter
> dropping unicast addresses that overflow the exact filter.
> The fix is simply to disable the filter by leaving count set
> to zero if we find non-multicast addresses after the exact
> match table is filled.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Doesn't it make more sense to remove the multicast check
in the filter check function?

With your change, the user gets absolutely no indication
that filtering has been completely disabled simply because
they put too many unicast addresses into the filter.  We
just return zero, that's crazy.
