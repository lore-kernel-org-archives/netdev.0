From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
 10/100/1000 Ethernet device driver
Date: Wed, 29 Jul 2015 12:14:01 -0700 (PDT)
Message-ID: <20150729.121401.1138495718406304622.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D53361B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbbG2TOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 15:14:04 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D53361B@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Mon, 27 Jul 2015 19:59:30 +0000

> +static int lan78xx_read_stats(struct lan78xx_net *dev,
> +			      struct lan78xx_statstage *data)
> +{
> +	int ret = 0;
> +	struct lan78xx_statstage *stats;
> +
> +	BUG_ON(!dev);
> +	BUG_ON(!data);
> +	BUG_ON(sizeof(struct lan78xx_statstage) != 0xBC);
> +
> +	stats = kmalloc(sizeof(*stats), GFP_KERNEL);
> +	if (!stats)
> +		return -ENOMEM;
> +
> +	ret = usb_control_msg(dev->udev,
> +			      usb_rcvctrlpipe(dev->udev, 0),
> +			      USB_VENDOR_REQUEST_GET_STATS,
> +			      USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
> +			      0,
> +			      0,
> +			      (void *)stats,
> +			      sizeof(*stats),
> +			      USB_CTRL_SET_TIMEOUT);
> +	if (likely(ret >= 0)) {
> +		le32_to_cpus(stats);
> +		*data = *stats;

This doesn't work.

le32_to_cpus() will only byte swap the first 'u32' in this statistics structure,
not all of them.

You have to explicitly byte swap each and every member.
