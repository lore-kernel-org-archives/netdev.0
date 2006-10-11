From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 20:42:20 -0700
Message-ID: <adak637bjs3.fsf@cisco.com>
References: <adavemrbtcx.fsf@cisco.com>
	<20061011002656.GB30093@mellanox.co.il> <adar6xfbk6d.fsf@cisco.com>
	<20061010.203624.91207079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@mellanox.co.il, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:38759 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1030769AbWJKDmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 23:42:22 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061010.203624.91207079.davem@davemloft.net> (David Miller's message of "Tue, 10 Oct 2006 20:36:24 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> Also, if you don't do checksumming on the card we MUST copy
    David> the data (be it from a user buffer, or from a filesystem
    David> page cache page) into a private buffer since if the data
    David> changes the checksum would become invalid, as I mentioned
    David> in another email earlier.

Yes, I get that now -- I replied to Michael's email before I read yours.

    David> Therefore, since we have to copy anyways, it always is
    David> better to checksum in parallel with the copy.

Yes.

    David> So the whole idea of SG without hw-checksum support is
    David> without much merit at all.

Well, on IB it is possible to implement a netdevice (IPoIB connected
mode, I assume that's what Michael is working on) with a large MTU
(64KB is a number thrown around, but really there's not any limit) but
no HW checksum capability.  Doing that in a practical way means we
need to allow non-linear skbs to be passed in.

On the other hand I'm not sure how useful such a netdevice would be --
will non-sendfile() paths generate big packets even if the MTU is 64KB?

Maybe GSO gives us all the real advantages of this anyway?

 - R.
