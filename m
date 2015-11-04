From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 04 Nov 2015 11:44:28 +0100
Message-ID: <5639E18C.9030108@hartkopp.net>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <814845359.20151103232627@cogentembedded.com> <56392607.5060200@hartkopp.net> <201511032241.09913.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.160]:55847 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbbKDKoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 05:44:34 -0500
In-Reply-To: <201511032241.09913.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marek,

On 03.11.2015 22:41, Marek Vasut wrote:
> On Tuesday, November 03, 2015 at 10:24:23 PM, Oliver Hartkopp wrote:


>> Comparing to typical ethernet frames with 1500 bytes the 16 bytes for CAN
>> frames or 72 bytes for CAN FD frames are already too small in relation to
>> the socket buffer overhead.
>>
>> If you want to improve the memory efficiency for arinc290 you should
>> probably consider to implement a character device based driver instead of
>> creating a new network protocol family.
>
> See discussion:
>
> http://comments.gmane.org/gmane.linux.kernel/1512019
>
> Which is why I picked the socket variant.
>

Oh. This provides a completely new perspective.

So far we just discussed about the 32 bit messages to be handled and filtered 
by the kernel.

This could have been done by

1. A chardev interface driver

2. A netdev interface driver (drivers/net/arinc429/...) and using PF_PACKET 
together with Berkley packet filtering (BPF)

3. A netdev interface driver (drivers/net/arinc429/...) and using PF_CAN which 
would lead to a arinc data structure which needs to be struct can_frame 
compatible.

But if you plan to implement the transport protocols (FTP/MAC) inside the 
Linux kernel that have been discussed in the URL above this would be a real 
difference to CAN related protocols. Only from that perspective a new protocol 
family would make sense.

(..)
>>  From what I've read so far there's also the sending of cyclic messages and
>> label filtering outside the HW - or why did you copy/paste the can_id/label
>> filter mechanism from af_can.c ?
>
> I think you might be mixing two people together here, I sent the patch and
> Andrey and Aleksander are working for some other interested company.

Sorry. Will try to bash only *you* in the future :-))

> The label filtering makes sense if you want to separate what you receive on
> which socket in userland, which allows an application to receive only relevant
> traffic.

ok.

>
> Hardware-accelerated filtering is another thing and at this point, we should
> not mix these two things. Does CAN framework have any such support for hardware
> assisted can_id filtering btw ?
>

No. We discussed about it. But the HW filter capabilities of CAN controllers 
have a wide range of functionality. Most filters make only sense in ECUs that 
pick specific CAN IDs for their functionality. It made no real sense to have 
an administrative configuration interface that limits the view to the CAN bus 
for the entire system. An we never had performance issues with the filtering 
in the softirq context in af_can.c

>>> I'd  prefer to have ARINC framework simple as it could be and separate
>>> from  CAN,  as  these  buses are not similar, besides desire to re-use
>>> SocketCAN interface/API to expose ARINC429 bus.
>>

>> Maybe you don't need that fancy stuff that comes with PF_CAN. Did you ever
>> thought about implementing a chardev driver for the ARINC429 hardware?
>> There are out-of-tree CAN drivers (e.g. can4linux or PEAK System Linux
>> driver) that handle the transfer of data structures (CAN frames) from/to
>> kernel space via character device. See an example at
>> https://en.wikipedia.org/wiki/Can4linux
>
> I guess I can answer that -- yes, I did, see above.
>

Ok - it seems to stick on the future plan whether it makes sense to implement 
the FTP/MAC transport protocols inside the kernel or not.

What's your thought about that?

Regards,
Oliver
