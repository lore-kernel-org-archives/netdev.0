From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V2] CAN: Add Flexcan CAN controller driver
Date: Tue, 28 Jul 2009 16:24:52 +0200
Message-ID: <20090728142452.GW2714@pengutronix.de>
References: <20090728120624.GS2714@pengutronix.de> <4A6EFB64.8070804@hartkopp.net> <20090728133719.GU2714@pengutronix.de> <4A6F0238.6050605@hartkopp.net> <4A6F073A.1050909@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57499 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbZG1OY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 10:24:56 -0400
Content-Disposition: inline
In-Reply-To: <4A6F073A.1050909@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 04:12:10PM +0200, Oliver Hartkopp wrote:
> Oliver Hartkopp wrote:
> > Sascha Hauer wrote:
> 
> >>>> +
> >>>> +	if (frame->can_id & CAN_RTR_FLAG)
> >>>> +		dlc |= MB_CNT_RTR;
> >>>> +
> >>>> +	writel(dlc, &regs->cantxfg[TX_BUF_ID].can_dlc);
> >>>> +	writel(can_id, &regs->cantxfg[TX_BUF_ID].can_id);
> 
> Are you sure, that this is correct?

Yes, I am sure, at least on my hardware.

> 
> Indeed i wonder, if it would make sense to skip the entire struct flexcan_mb
> approach and fiddle byte-by-byte inside the registers ...

You'll have to to 32 bit accesses to get it right on little and big
endian.

what we can do is:

writel(can_data[0] << 24 | can_data[1] << 16 | can_data[2] << 8 | can_data[3],
	msg_buf + 0x8);

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
