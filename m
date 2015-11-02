From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Mon, 02 Nov 2015 20:55:33 +0100
Message-ID: <5637BFB5.6070706@hartkopp.net>
References: <1446419775-5215-1-git-send-email-marex@denx.de>	<56373140.6040003@pengutronix.de>	<56374593.6000200@hartkopp.net> <CAAP7ucKOzP=HX4qJPhLN0c8nBHpCfzskBxtO09=K7HLLu_iT2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Andrey Vostrikov <andrey.vostrikov@cogentembedded.com>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:47536 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbKBUBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:01:50 -0500
In-Reply-To: <CAAP7ucKOzP=HX4qJPhLN0c8nBHpCfzskBxtO09=K7HLLu_iT2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2015 08:41 PM, Aleksander Morgado wrote:
> On Mon, Nov 2, 2015 at 12:14 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>>
>> What about defining some overlay data structure to map ARINC-429 frames into
>> CAN frames?
>>
>> E.g. we could write the ARINC 32 bit data completely into data[0..3] and
>> additionally copy the 8 bit label information (or should it better be 10 bit
>> including the Source/Destination Identifiers?) additionally into the can_id.
> 
> Note that the only bits which are always treated as non-data are the 8
> label bits (well, and the parity bit #31). The 2 SDI bits (#8, #9) may
> be used as data bits when a high resolution is needed, like Lat/Long
> encoded in binary words 310 and 311. I wouldn't make any assumption on
> what's on those 2 bits; i.e. they're not always "source/destination".
> 

You definitely know these details better than me. That's why I'm asking.

Would hosting the 32 bit in the struct can_frame.data and just the 8 bit label
in struct can_frame.can_id offer the functionality you need?

Besides the arinc429_frame struct

struct arinc429_frame {
	__u8	label;		/* 8 bit label */
	__u8	data[3];	/* Up-to 23 bits are valid. */
};

everything else roughly looks like copy&paste from PF_CAN with renaming.

So when we can fit the arinc frames into CAN frames and re-use the existing
CAN infrastructure - we are almost done.

Regards,
Oliver
