From: David Miller <davem@davemloft.net>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 20:36:24 -0700 (PDT)
Message-ID: <20061010.203624.91207079.davem@davemloft.net>
References: <adavemrbtcx.fsf@cisco.com>
	<20061011002656.GB30093@mellanox.co.il>
	<adar6xfbk6d.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@mellanox.co.il, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57542
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030776AbWJKDgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 23:36:21 -0400
To: rdreier@cisco.com
In-Reply-To: <adar6xfbk6d.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 10 Oct 2006 20:33:46 -0700

>     Michael> My guess was, an extra pass over data is likely to be
>     Michael> expensive - dirtying the cache if nothing else. But I do
>     Michael> plan to measure that, and see.
> 
> I don't get it -- where's the extra pass?  If you can't compute the
> checksum on the NIC then you have to compute sometime it on the CPU
> before passing the data to the NIC.

Also, if you don't do checksumming on the card we MUST copy
the data (be it from a user buffer, or from a filesystem page
cache page) into a private buffer since if the data changes
the checksum would become invalid, as I mentioned in another
email earlier.

Therefore, since we have to copy anyways, it always is better
to checksum in parallel with the copy.

So the whole idea of SG without hw-checksum support is without
much merit at all.
