From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: [PATCH 1/2] usbnet: changes for upcoming cdc_ncm driver
Date: Wed, 24 Nov 2010 16:14:44 +0100
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153BA8799667@EXDCVYMBSTM006.EQ1STM.local>
References: <1290531088-2393-1-git-send-email-alexey.orishko@stericsson.com>
 <1290538720.2529.109.camel@helium>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@suse.de" <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"oliver@neukum.org" <oliver@neukum.org>,
	"yauheni.kaliuta@nokia.com" <yauheni.kaliuta@nokia.com>,
	"balbi@ti.com" <balbi@ti.com>,
	Sjur BRENDELAND <sjur.brandeland@stericsson.com>,
	Alexey ORISHKO <alexey.orishko@stericsson.com>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:56595 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751693Ab0KXPPA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 10:15:00 -0500
In-Reply-To: <1290538720.2529.109.camel@helium>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> > -		skb_queue_tail (&dev->done, skb);
> > +	if (skb->len) {
> > +		/* all data was already cloned inside NCM driver */
> 
> Fix this comment.  NCM isn't the only framing policy which un-batches
> RX packets ... RNDIS has done so for a number of years already, and
> more recently EEM needs it too ... plus at least one hardware driver.

Will do.

> Also, check pending patches, since I seem to recall one that supports
> some hardware (SMSC?) that batches, and needed to update the calling
> convention you're using here (i.e. the original one).

Patch was based on linux-next git and I don't see any difference from
net-next. Any particular git you'd like me to look at pending patches?

> 
> 
> > +		if (dev->driver_info->flags & FLAG_MULTI_PACKET)
> 
> except ... you documented this flag as affecting TX paths not RX...

This flag carries two purposes:
- help to correct statistic (Tx/Rx counting)
- handle NCM feature to avoid sending short packets in certain
conditions: cdc_ncm driver has to send short packet (or ZLP) only
if data size is not equal to negotiated data size (dwNtbOutMaxSize).

The other option (instead of dedicated flag) would be to add
additional field in the usbnet context structure, which will keep
dwNtbOutMaxSize value (it still would be better to use
dedicated flag in addition to the value). Thus usbnet would possess
the knowledge when ZLP or short packet should be skipped.
By doing this approach we will eliminate a need to generate short
packet inside the driver and use generic code in usbnet.

Could you comment, what would be the preferable way to get it in the
next version of this patch?

Regards,
Alexey

