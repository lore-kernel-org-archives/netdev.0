From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 23:13:16 -0700 (PDT)
Message-ID: <20070318.231316.59470365.davem@davemloft.net>
References: <20070318224234.GP11078@mellanox.co.il>
	<20070318.171337.112622504.davem@davemloft.net>
	<m3aby94x6o.fsf@maxwell.lnxi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@dev.mellanox.co.il, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: ebiederman@lnxi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965671AbXCSGNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 02:13:16 -0400
In-Reply-To: <m3aby94x6o.fsf@maxwell.lnxi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederman@lnxi.com (Eric W. Biederman)
Date: Sun, 18 Mar 2007 23:30:39 -0600

> Sure.  In the network namespace case I think the careful ordering of the
> shutdown handles that case.   Even with per network namespace lo
> unregistered it still existed until the network namespace actually
> exited.  And it only happened on exit.  
> 
> So while there may be a tiny race there it hasn't been an issue yet
> in practice.

I think the thing to do is to just leave the loopback references
in place, try to unregister the per-namespace loopback device,
and that will safely wait for all the references to go away.

If you do it that way, you should need absolutely no changes to
the other code in this area.

As per Herbert, I think he works on Xen rather than vserver :-)
Perhaps you're thinking of Alexey Kuznetsov or another one of the
vserver guys.
