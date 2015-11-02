From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Mon, 02 Nov 2015 12:14:27 +0100
Message-ID: <56374593.6000200@hartkopp.net>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <56373140.6040003@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Andrey Vostrikov <andrey.vostrikov@cogentembedded.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Marek Vasut <marex@denx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:16789 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027AbbKBLOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 06:14:39 -0500
In-Reply-To: <56373140.6040003@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.11.2015 10:47, Marc Kleine-Budde wrote:
> On 11/02/2015 12:16 AM, Marek Vasut wrote:
>> The ARINC-429 is a technical standard, which describes, among others,
>> a data bus used by airplanes. The standard contains much more, since
>> it is based off the ISO/OSI model, but this patch implements just the
>> data bus protocol.
>>
>> This stack is derived from the SocketCAN implementation, already present
>> in the kernel and thus behaves in a very similar fashion. Thus far, we
>> support sending RAW ARINC-429 datagrams, configuration of the RX and TX
>> clock speed and filtering.
>>
>> The ARINC-429 datagram is four-byte long. The first byte is always the
>> LABEL, the function of remaining three bytes can vary, so we handle it
>> as an opaque PAYLOAD. The userspace tools can send these datagrams via
>> a standard socket.
>>
>> A LABEL-based filtering can be configured on each socket separately in
>> a way comparable to CAN -- user uses setsockopt() to push a list of
>> label,mask tuples into the kernel and the kernel will deliver a datagram
>> to the socket if (<received_label> & mask) == (label & mask), otherwise
>> the datagram is not delivered.
>
> What's difference compared to CAN besides a different MTU? The CAN stack
> is already capable to handle CAN and CAN-FD frames. Would it make sense
> to integrate the ARINC-429 into the existing CAN stack?

That was my first impression too.

What about defining some overlay data structure to map ARINC-429 frames into 
CAN frames?

E.g. we could write the ARINC 32 bit data completely into data[0..3] and 
additionally copy the 8 bit label information (or should it better be 10 bit 
including the Source/Destination Identifiers?) additionally into the can_id.

 From what I can see the filtering by label is similar to filtering by can_id.
And you would be able to use the can-gw functionality too.

The only real difference is the bitrate configuration of the ARINC interface.

I wonder if a similar approach would fit here as we discussed with the 
University of Prague for a LIN implementation using the PF_CAN infrastructure:

http://rtime.felk.cvut.cz/can/lin-bus/

It could probably boil down to a 'CAN interface' that is named arinc0 which 
implements the serial driver like in slcan.c or sllin.c ...

Regards,
Oliver
