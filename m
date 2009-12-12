From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH net-2.6] can: Fix data length code handling in rx path
Date: Sat, 12 Dec 2009 18:37:18 +0100
Message-ID: <4B23D4CE.30005@hartkopp.net>
References: <4B23A501.9000208@hartkopp.net> <4B23C602.7050302@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-fb.rzone.de ([81.169.146.163]:13908 "HELO
	mo-p00-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750847AbZLMDty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 22:49:54 -0500
Received: from mo-p00-ob.rzone.de (fruni-mo-p00-ob.mail [192.168.63.71])
	by scum-fb-04.store (RZmta 22.5) with ESMTP id R03db8lBCHBbpM
	for <netdev@vger.kernel.org>; Sat, 12 Dec 2009 19:51:43 +0100 (MET)
In-Reply-To: <4B23C602.7050302@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Hi Oliver,
> 
> Oliver Hartkopp wrote:
>> A valid CAN dataframe can have a data length code (DLC) of 0 .. 8 data bytes.
>>
>> When reading the CAN controllers register the 4-bit value may contain values
>> from 0 .. 15 which may exceed the reserved space in the socket buffer!
>>
>> The ISO 11898-1 Chapter 8.4.2.3 (DLC field) says that register values > 8
>> should be reduced to 8 without any error reporting or frame drop.
>>
>> This patch introduces a new helper macro to cast a given 4-bit data length
>> code (dlc) to __u8 and ensure the DLC value to be max. 8 bytes.
>>
>> The different handlings in the rx path of the CAN netdevice drivers are fixed.
>>
>> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> 
> Please send you patches inline next time please. For the bfin_can and
> the ems_usb driver your patch now masks the dlc with 0xf. Are you sure
> this is needed or even correct?

Yes. Both needed to be fixed.

The bfin_can has an u16 value which is not reduced to 4-bits before.
The ems_usb driver gets a u8 value via USB urb, which comes from a SJA1000 and
needs the same handling as in the sja1000 driver. There's no guarantee that
the USB adapter handles the values correctly - so masking is appropriate here.

> Also, s/__u8/u8/, please.

can_frame.can_dlc is the target and it is defined as '__u8' in
include/linux/can.h.

As discussed on SocketCAN-ML we agreed the at91_can.c to be the 'correct'
implementation - and that's what i posted here on your request ... :-)

IMO the patch remains 100% correct.

Best regards,
Oliver

