From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when promiscuous mode
Date: Tue, 13 Nov 2007 20:16:47 +0800
Message-ID: <20071113121647.GA1330@gondor.apana.org.au>
References: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au> <20071113.033611.73195922.davem@davemloft.net> <20071113120328.GB1086@gondor.apana.org.au> <20071113.040624.43544149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, joonwpark81@gmail.com, w@1wt.eu,
	cfriesen@nortel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1677 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754316AbXKMMRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 07:17:14 -0500
Content-Disposition: inline
In-Reply-To: <20071113.040624.43544149.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 04:06:24AM -0800, David Miller wrote:
>
> > In other words we can make it so that nobody is in promiscuous
> > mode and therefore have to disable VLAN acceleration *unless*
> > they really want to be in that state.  In which case it would
> > imply that they wish to see everything and therefore we should
> > disable VLAN acceleration.
> 
> This is too complicated, we have multiple unicast MAC support
> in the driver API already, let's simply use it.

Yes I agree.  People not using Patrick's new API deserves to
get poor performance so they can switch over sooner :)

What I was trying to say above is that e1000 currently uses
the old set_multicast_list interface (rather than dev_set_rx_mode)
so it's not immediately obvious why we're in promiscuous mode.
We could look at dev->promiscuity - !!uc_count but that feels a
bit fragile.

Perhaps those who want to push this patch should be encouraged
to convert e1000 to the new interface :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
