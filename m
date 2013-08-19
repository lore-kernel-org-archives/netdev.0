From: "Schmitt, Sven (EVM/E)" <Sven.Schmitt@volkswagen.de>
Subject: Re: [PATCH 6/7] net: add the AF_FLEXRAY protocol
Date: Mon, 19 Aug 2013 15:00:46 +0000
Message-ID: <9A7272FCC21A8A47ADC46F543B78FB03173CC2A2@VWAGWOXD0402.vw.vwg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: "'b.spranger@linutronix.de'" <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mr2.volkswagen.de ([194.114.62.76]:51687 "EHLO
	mr2.volkswagen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab3HSPGH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 11:06:07 -0400
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.08.2013 11:08, Benedikt Spranger wrote:
> FlexRay is a networking technology used in automotive fields as
> successor of the Controller Area Network (CAN). It provides the
> core functionality and a RAW protocol driver.
>
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
> Documentation/networking/00-INDEX             |   2 +
> Documentation/networking/flexray.txt          |  24 ++
> include/linux/flexray.h                       | 168 ++++++++

Hello Benedikt,

thanks for bringing flexray to linux.

Some general remarks/questions:
- how can errors (crc, boundary, tx on not empty slot) be transported by the frame like in a CAN frame (/include/uapi/linux/can/error.h):
	-> canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */ ? 
	...there is no more space in the id field in your frame definition.
- what about special bus content like wakeup pattern (WUP), collision avoidance symbol (CAS) and media test symbols (MTS). These are interesting for logging use cases.
- do we need the crc fields? What happens if the cr check fails (-> error flag)? Do we need this information then?
- do we need the reserved bit? (there is none in CAN frame definition)

Best regards,
Sven
