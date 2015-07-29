From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
 10/100/1000 Ethernet device driver
Date: Wed, 29 Jul 2015 21:57:52 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D537333@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D53361B@CHN-SV-EXMX02.mchp-main.com>
 <20150729.121401.1138495718406304622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp02.microchip.com ([198.175.253.38]:54456 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753341AbbG2V5x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:57:53 -0400
In-Reply-To: <20150729.121401.1138495718406304622.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for review and comment.
Will repost  after update.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, July 29, 2015 3:14 PM
> To: Woojung Huh - C21699
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
> 10/100/1000 Ethernet device driver
> 
> From: <Woojung.Huh@microchip.com>
> Date: Mon, 27 Jul 2015 19:59:30 +0000
> 
> > +static int lan78xx_read_stats(struct lan78xx_net *dev,
> > +			      struct lan78xx_statstage *data)
> > +{
> > +	int ret = 0;
> > +	struct lan78xx_statstage *stats;
> > +
> > +	BUG_ON(!dev);
> > +	BUG_ON(!data);
> > +	BUG_ON(sizeof(struct lan78xx_statstage) != 0xBC);
> > +
> > +	stats = kmalloc(sizeof(*stats), GFP_KERNEL);
> > +	if (!stats)
> > +		return -ENOMEM;
> > +
> > +	ret = usb_control_msg(dev->udev,
> > +			      usb_rcvctrlpipe(dev->udev, 0),
> > +			      USB_VENDOR_REQUEST_GET_STATS,
> > +			      USB_DIR_IN | USB_TYPE_VENDOR |
> USB_RECIP_DEVICE,
> > +			      0,
> > +			      0,
> > +			      (void *)stats,
> > +			      sizeof(*stats),
> > +			      USB_CTRL_SET_TIMEOUT);
> > +	if (likely(ret >= 0)) {
> > +		le32_to_cpus(stats);
> > +		*data = *stats;
> 
> This doesn't work.
> 
> le32_to_cpus() will only byte swap the first 'u32' in this statistics structure,
> not all of them.
> 
> You have to explicitly byte swap each and every member.
