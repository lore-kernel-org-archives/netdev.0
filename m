From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC] fix problems with NETIF_F_HIGHDMA in networking drivers v2
Date: Wed, 10 Mar 2010 12:17:00 -0800
Message-ID: <adar5nshqyr.fsf@roland-alpha.cisco.com>
References: <4B8F213B.40603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linux-usb <linux-usb@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
To: Robert Hancock <hancockrwd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:54918 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756976Ab0CJURG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 15:17:06 -0500
In-Reply-To: <4B8F213B.40603@gmail.com> (Robert Hancock's message of "Wed, 03
	Mar 2010 20:55:55 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
 > index df3eb8c..53be462 100644
 > --- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
 > +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
 > @@ -1058,7 +1058,7 @@ static void ipoib_setup(struct net_device *dev)
 >  	dev->type		 = ARPHRD_INFINIBAND;
 >  	dev->tx_queue_len	 = ipoib_sendq_size * 2;
 >  	dev->features		 = (NETIF_F_VLAN_CHALLENGED	|
 > -				    NETIF_F_HIGHDMA);
 > +				    NETIF_F_DMA_HIGH);
 >  	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 >  
 >  	memcpy(dev->broadcast, ipv4_bcast_addr, INFINIBAND_ALEN);

Been meaning to mention this for a bit, but ipoib is capable of handling
any DMA address, so if I understand your patch correctly, this can be
NETIF_F_DMA_64BIT instead of just DMA_HIGH.
-- 
Roland Dreier  <rolandd@cisco.com>
For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
