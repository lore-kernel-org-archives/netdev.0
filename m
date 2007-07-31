From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support for	the	bonding
	driver
Date: Tue, 31 Jul 2007 17:48:27 +0300
Message-ID: <20070731144827.GB17331@mellanox.co.il>
References: <46ADDB89.5030601@voltaire.com> <adaejipr3l5.fsf@cisco.com>
	<46AF3CA8.6050201@gmail.com>
	<20070731140436.GA16015@mellanox.co.il>
	<46AF44E0.50700@voltaire.com>
	<20070731142234.GC16015@mellanox.co.il>
	<46AF48D5.9000502@voltaire.com>
Reply-To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	fubar@us.ibm.com, davem@davemloft.net,
	general@lists.openfabrics.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:62715 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264AbXGaOsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 10:48:25 -0400
Received: by ug-out-1314.google.com with SMTP id j3so89300ugf
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 07:48:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <46AF48D5.9000502@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Quoting Or Gerlitz <ogerlitz@voltaire.com>:
> Subject: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support for?the?bonding driver
> 
> Michael S. Tsirkin wrote:
> >>Quoting Or Gerlitz <ogerlitz@voltaire.com>:
> 
> >>To be precise, bonding will copy all the symbols it copies today from 
> >>the slave module (ipoib), see bond_setup_by_slave() in patch 3/7
> 
> >Not really.
> >This copying of symbols is something that you added, isn't it?
> >So with this approach, it won't be needed.
> 
> >It's always wrong to copy symbols from another module without
> >referencing it.
> 
> Its the --first-- time you make this comment,

It's really a well known fact. That's where the crash
with modprobe -r comes from, right?

> please suggest a different approach,

I don't know, really - if you want to access a module, you really must get
a reference to it, or to the device.
How about adding the module pointer to struct net_device?

>the relevant code is below.

>+static void bond_setup_by_slave(struct net_device *bond_dev,
>+				struct net_device *slave_dev)
>+{
>+	bond_dev->hard_header	        = slave_dev->hard_header;
>+	bond_dev->rebuild_header        = slave_dev->rebuild_header;
>+	bond_dev->hard_header_cache	= slave_dev->hard_header_cache;
>+	bond_dev->header_cache_update   = slave_dev->header_cache_update;
>+	bond_dev->hard_header_parse	= slave_dev->hard_header_parse;
>+
>+	bond_dev->neigh_setup           = slave_dev->neigh_setup;
>+
>+	bond_dev->type		    = slave_dev->type;
>+	bond_dev->hard_header_len   = slave_dev->hard_header_len;
>+	bond_dev->addr_len	    = slave_dev->addr_len;
>+
>+	memcpy(bond_dev->broadcast, slave_dev->broadcast,
>+		slave_dev->addr_len);
>+}
>+

Hmm, it seems that switching to hard_header_cache as I suggested won't help at all.
I wonder: is bonding currently broken with devices that implement
hard_header_cache/header_cache_update?

-- 
MST
