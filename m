From: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Mon, 2 Nov 2015 23:15:21 +0300
Message-ID: <666821254.20151102231521@cogentembedded.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
  <56373140.6040003@pengutronix.de> <56374593.6000200@hartkopp.net>
  <201511021916.18117.marex@denx.de>
Reply-To: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:36546 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbKBUPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:15:34 -0500
Received: by lffz202 with SMTP id z202so67067185lff.3
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 12:15:33 -0800 (PST)
In-Reply-To: <201511021916.18117.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> I was thinking about this and I mostly agree with you. Obviously, copying the
> code this way was dumb. On the other hand, ARINC and CAN are two different sort
> of busses, so I'd propose something slightly different here to avoid confusion
> and prevent the future extensions (or protocols) from adding unrelated cruft
> into the CAN stack.

Another  major  difference  between  CAN and ARINC429 is that ARINC is
simplex.  It  does  not  need  loopback  and echo. For example HOLT IC
chip  HI-3593  has  two receivers and single transmitter, which
should  be  instantiated as separate devices, as each channel could be
connected to different network.

It  would  be nice if new ARINC framework will provide means to create
RX  or  TX  only  network device and have -rx- or -tx- as part of device
name.

Label  space in ARINC is much smaller than in CAN, is it really needed
to  have  hash  and  masks? May be simple bitmap for 256 bits will fit
better.  At least it could be directly provided to mentioned HOLT chip
to do filtering in hardware.

-- 
Best regards,
Andrey
