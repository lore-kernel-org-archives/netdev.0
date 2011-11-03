From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Thu, 03 Nov 2011 15:54:50 +0100
Message-ID: <4EB2AB3A.6050901@hartkopp.net>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET .INT> <20111102080438.GA324@e-circ.dyndns.org> <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA803@exch01-aklnz.MARINE.NET.INT> <4EB1A883.2040605@hartkopp.net> <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Reuben Dowle <Reuben.Dowle@navico.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:32590 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab1KCOzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 10:55:08 -0400
In-Reply-To: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.11.2011 22:31, Reuben Dowle wrote:

>>>
>>> If we change the behaviour of flexcan, I think at91 and slcan should
>> be changed too, because this should be handled consistently across all
>> drivers I would think.
>>
>>
>> At least the slcan driver does not support the correct echo of CAN
>> frames on
>> driver level at all. The slcan driver adapts CAN frames to a serial
>> line CAN
>> adapter where the feedback of successful transmission is not
>> guaranteed/checked within the serial data stream. Therefore the
>> interface flag
>> IFF_ECHO is not set in the slcan driver and the local echo is performed
>> in
>> af_can.c (as a workaround).
>>
>> Regards,
>> Oliver
> 
> Thats fine for the echo behaviour, but does not really answer why the slcan
> (and flexcan) driver is setting the stats for tx_packets and tx_bytes at 
> different points in the transmission logic. To my mind, either we think the
> packet has transmitted (along with its bytes) so we should increment both,
> or we should increment neither.


In slcan.c the points of incrementing tx_bytes and tx_packets have been
adopted from slip.c where slcan.c heavily bases on.

Indeed one could argument that tx_packets could be incremented in slc_encaps
together with tx_bytes. This means that the packet is sent.

But the packet is surely sent in slcan_write_wakeup(), when tx_packets is
incremented. Unfortunately we do not have the can_dlc available at this point
anymore.

If you think it's worth the effort tx_packets++ could be integrated into
slc_encaps() to have a consistent statistic update (but you don't know whether
the packet hit the serial line entirely).

Additionally slip.c does it the same (inconsistent) way for the reasons above
and therefore i tend not to change it to stay on the current serial netdevices
behaviour (for slcan as only CAN netdevice).

Regards,
Oliver
