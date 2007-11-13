From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when
 promiscuous mode
Date: Tue, 13 Nov 2007 04:06:24 -0800 (PST)
Message-ID: <20071113.040624.43544149.davem@davemloft.net>
References: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au>
	<20071113.033611.73195922.davem@davemloft.net>
	<20071113120328.GB1086@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, joonwpark81@gmail.com, w@1wt.eu,
	cfriesen@nortel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753944AbXKMMGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 07:06:24 -0500
In-Reply-To: <20071113120328.GB1086@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 13 Nov 2007 20:03:28 +0800

> On Tue, Nov 13, 2007 at 03:36:11AM -0800, David Miller wrote:
> >
> > The performance implications can be pretty severe however.
> > I wish we could address this somehow.
> 
> Or perhaps we should just teach everyone to always run tcpdump
> with -p, like me :)

:-)

> Of course this would still have a negative impact on those who
> have to be in promiscuous mode all the time (heh) due to multiple
> unicast MAC addresses and such.  However, we should able to
> communicate that fact to the driver and the driver can then elect
> to not disable VLAN acceleration unless we really want to be in
> promiscuous mode.

We already do with the code Patrick added a while ago so
that drivers can support multiple MAC addresses in hardware.

Now just to get the virtualization technologies and all the
drivers using it properly.

> In other words we can make it so that nobody is in promiscuous
> mode and therefore have to disable VLAN acceleration *unless*
> they really want to be in that state.  In which case it would
> imply that they wish to see everything and therefore we should
> disable VLAN acceleration.

This is too complicated, we have multiple unicast MAC support
in the driver API already, let's simply use it.
