From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v6 1/3] ieee802154: cc2520: adds driver for TI
 CC2520 radio
Date: Fri, 20 Jun 2014 13:24:34 +0200
Message-ID: <20140620112432.GA5013@omega>
References: <1403243294-15400-1-git-send-email-varkab@cdac.in>
 <1403243294-15400-2-git-send-email-varkab@cdac.in>
 <20140620083218.GA4116@omega>
 <53A40CB0.4080308@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	devicetree@vger.kernel.org, sowjanyap@cdac.in, venkatas@cdac.in,
	santoshk@cdac.in
To: Varka Bhadram <varkab@cdac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:59996 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966619AbaFTLYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 07:24:44 -0400
Content-Disposition: inline
In-Reply-To: <53A40CB0.4080308@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2014 at 03:58:00PM +0530, Varka Bhadram wrote:
> Hi Alex,
> 
> On 06/20/2014 02:02 PM, Alexander Aring wrote:
> >Hi Varka,
> >
> >sorry for my careful reviewing...,, but I had also some patch series
> >which was at v8 or something like that. :-)
> 
> mhhh.. More careful review produces the best code ...
> 
> >On Fri, Jun 20, 2014 at 11:18:12AM +0530, Varka Bhadram wrote:
> >>This patch adds the driver support for the cc2520 radio.
> >>
> >>Driver support:
> >>         - Tx and Rx of IEEE-802.15.4 packets.
> >>         - Energy Detection on channel.
> >>         - Setting the Channel for the radio. [b/w 11 - 26 channels]
> >>         - Start and Stop the radio
> >>         - h/w address filtering.
> >>
> >>Signed-off-by: Varka Bhadram <varkab@cdac.in>
> >>---
> >>  drivers/net/ieee802154/cc2520.c | 1045 +++++++++++++++++++++++++++++++++++++++
> >>  include/linux/spi/cc2520.h      |   26 +
> >>  2 files changed, 1071 insertions(+)
> >>  create mode 100644 drivers/net/ieee802154/cc2520.c
> >>  create mode 100644 include/linux/spi/cc2520.h
> >>
> >>diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
> >>new file mode 100644
> >>index 0000000..fff7fd2
> >>--- /dev/null
> >>+++ b/drivers/net/ieee802154/cc2520.c
> >>@@ -0,0 +1,1045 @@
> >>+/* Driver for TI CC2520 802.15.4 Wireless-PAN Networking controller
> >>+ *
> >>+ * Copyright (C) 2014 Varka Bhadram <varkab@cdac.in>
> >>+ *		      Md.Jamal Mohiuddin <mjmohiuddin@cdac.in>
> >>+ *		      P Sowjanya <sowjanyap@cdac.in>
> >>+ *
> >>+ * This program is free software; you can redistribute it and/or modify
> >>+ * it under the terms of the GNU General Public License as published by
> >>+ * the Free Software Foundation; either version 2 of the License, or
> >>+ * (at your option) any later version.
> >>+ *
> >>+ */
> >>+
> >...
> >
> >>+
> >>+/* Driver private information */
> >>+struct cc2520_private {
> >>+	struct spi_device *spi;		/* spi device structure */
> >>+	struct ieee802154_dev *dev;	/* Ieee802.15.4 device */
> >why lowercase IEEE in the comment? :-)
> 
> Ok.
> 
> >>+	u8 *buf;			/* SPI TX/Rx data buffer */
> >>+	struct mutex buffer_mutex;	/* SPI buffer mutex */
> >>+	unsigned is_tx:1;		/* Flag for sync b/w Tx and Rx */
> >bool/int?
> 
> I think there is no difference b/w 'unsigned' and 'unsigned int'. But it will be clear if we use 'unsigned int'
> 

I meant the bitfield here. I only see bitfields if we they use that for
more than one bitfield. is_tx:1 is more a bool.

- Alex
