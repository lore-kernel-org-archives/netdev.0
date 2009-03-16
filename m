From: David Miller <davem@davemloft.net>
Subject: Re: Kernel panic during stress with igb in the upstream kernel
Date: Sun, 15 Mar 2009 20:13:53 -0700 (PDT)
Message-ID: <20090315.201353.57364397.davem@davemloft.net>
References: <EA929A9653AAE14F841771FB1DE5A1365F69CA4280@rrsmsx501.amr.corp.intel.com>
	<20090313115245.GA31949@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, alexander.h.duyck@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752604AbZCPDOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 23:14:06 -0400
In-Reply-To: <20090313115245.GA31949@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 13 Mar 2009 19:52:45 +0800

> Sorry, it seems that I've managed to get the net/net-next patches
> mixed up.  Does this help?

Actually I introduced this problem when I did the net-2.6
--> net-next-2.6 merge when your netpoll fix went it. :-/

> GRO: Move netpoll checks to correct location
> 
> As my netpoll fix for net doesn't really work for net-next, we
> need this update to move the checks into the right place.  As it
> stands we may pass freed skbs to netpoll_receive_skb.
> 
> This patch also introduces a netpoll_rx_on function to avoid GRO
> completely if we're invoked through netpoll.  This might seem
> paranoid but as netpoll may have an external receive hook it's
> better to be safe than sorry.  I don't think we need this for
> 2.6.29 though since there's nothing immediately broken by it.
> 
> This patch also moves the GRO_* return values to netdevice.h since
> VLAN needs them too (I tried to avoid this originally but alas
> this seems to be the easiest way out).  This fixes a bug in VLAN
> where it continued to use the old return value 2 instead of the
> correct GRO_DROP.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
