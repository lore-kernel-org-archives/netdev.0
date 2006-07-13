From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Thu, 13 Jul 2006 13:47:35 -0700 (PDT)
Message-ID: <20060713.134735.23014475.davem@davemloft.net>
References: <20060708104811.GB31751@lst.de>
	<20060708.133738.123994596.davem@davemloft.net>
	<20060713203615.GA26954@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org, support@pathscale.com,
	samuel@sortiz.org, kkeil@suse.de, kai.germaschewski@gmx.de,
	chas@cmf.nrl.navy.mil, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17375
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030378AbWGMUrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 16:47:32 -0400
To: hch@lst.de
In-Reply-To: <20060713203615.GA26954@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Thu, 13 Jul 2006 22:36:16 +0200

>  - drivers/atm/{idt77252.c, nicstar.c}, drivers/usb/atm/usbatm.c:
> 	These use private skb queues and do odd things.  I can't see
> 	any point for using dev_alloc_skb with it's additional headroom
> 	reservation here.
>  - drivers/isdn/<everything> :
> 	These don't even have a netdevice!  Also I can't see why they
> 	need the headroom.
>  - drivers/net/{ppp_async.c,drivers/net/ppp_async.c}:
>    	They take data from the underlying tty device.  Because of that
> 	there's not point for he additional headroom.
>  - net/irda/*:
>    	They allocate the skb in protocol code for TX.  Should probably
> 	do a normal alloc_skb like all the other protocol code.
>  - drivers/infiniband/hw/ipath/ipath_driver.c:
>    	Uses skbbuffs in a driver that has absolutely nothing to do
> 	with networking.  Duh..

Any of these cases that DMA into the skb allocated will need
the headroom, as explained by the PowerPC folks.

I can see how PPP just copies into the skb, but some of the
ISDN bits will be doing DMA won't they?

I agree that IRDA's transmit side shouldn't be calling
dev_alloc_skb.
