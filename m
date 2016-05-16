From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH -next v2 3/4] net: w5100: increase TX timeout period
Date: Mon, 16 May 2016 09:33:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4BF7F1@AcuExch.aculab.com>
References: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
 <1463205350-7089-4-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Mike Sinkovsky <msink@permonline.ru>,
	"David S . Miller" <davem@davemloft.net>
To: 'Akinobu Mita' <akinobu.mita@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:50886 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbcEPJfA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 05:35:00 -0400
In-Reply-To: <1463205350-7089-4-git-send-email-akinobu.mita@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: netdev-owner@vger.kernel.org Akinobu Mita
> Sent: 14 May 2016 06:56
> This increases TX timeout period from one second to 5 seconds which is
> the default value if the driver doesn't explicitly set
> net_device->watchdog_timeo.
> 
> The one second timeout is too short for W5100 with SPI interface mode
> which doesn't support burst READ/WRITE processing in the SPI transfer.
> If the packet is transmitted while RX packets are being received at a
> very high rate, the TX transmittion work in the workqueue is delayed
> and the watchdog timer is expired.

ISTM that if RX traffic can cause a 1 second timeout to expire I can
see no reason why it shouldn't also cause a 5 second timer to expire.

I'm guessing that something needs to be done to cause the SPI
block to discard receive frames (I guess the hardware will be discarding
them as well) in order to allow frames to be transmitted.

Given the 'damp string' nature of SPI, you might even want to give
transmits priority over receives.

	David
