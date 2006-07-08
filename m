From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Sat, 08 Jul 2006 13:37:38 -0700 (PDT)
Message-ID: <20060708.133738.123994596.davem@davemloft.net>
References: <20060707155255.10f2e10f@dxpl.pdx.osdl.net>
	<20060707.165527.77037268.davem@davemloft.net>
	<20060708104811.GB31751@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62625
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030355AbWGHUiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 16:38:08 -0400
To: hch@lst.de
In-Reply-To: <20060708104811.GB31751@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sat, 8 Jul 2006 12:48:12 +0200

> My plan is to give dev_alloc_skb a struct netdevice * argument and
> introduce a alloc_netdev_node so the driver can tell what node the
> device is on.  This gives a significant speedup for cell.  I already
> have this implemented in fact but only converted a handfull of drivers.
> 
> Does this approach sound okay?

I do not think it is feasible to add a netdevice argument to
such a widely used interface.

I would instead recommend that you add a new interface, and
we convert drivers gradually.

That netdevice argument is useful for other things.  For example,
you can use it to apply a per-netdev random memory allocation
failure setting, to test the robustness of drivers.  I came up
with that idea something like 7 years ago but never got around
to doing it :)

