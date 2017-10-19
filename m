From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Thu, 19 Oct 2017 20:35:07 +0200
Message-ID: <f651ffd4-826c-ee20-aebf-e3c2c1b89ecf@hartkopp.net>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <848e965d-e6a1-8930-9064-0317563326c0@ti.com>
 <93c6d531-c38b-6f88-510f-59eb3e733b78@ti.com>
 <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
 <a972cec1-3386-3ca3-ace3-175e1cabd286@hartkopp.net>
 <0099eefa-32c8-a818-761c-667239d9ec3b@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>,
        "Quadros, Roger" <rogerq@ti.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Sekhar Nori <nsekhar@ti.com>,
        Franklin S Cooper Jr <fcooper@ti.com>,
        =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, wg@grandegger.com,
        quentin.schulz@free-electrons.com, edumazet@google.com,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:18953 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754363AbdJSSfU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 14:35:20 -0400
In-Reply-To: <0099eefa-32c8-a818-761c-667239d9ec3b@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marc,

On 10/19/2017 01:26 PM, Marc Kleine-Budde wrote:
> On 10/19/2017 01:14 PM, Oliver Hartkopp wrote:
>>>>>> Since we have a netlink socket interface to configure sample point, I
>>>>>> wonder if that should be extended to configure SSP too (or at least the
>>>>>> offset part of SSP)?
>>
>> +1 too
> 
> The struct can_bittiming in defined in uapi, so we have to keep ABI
> compatibility in mind.
> 

Oh, this is fortunately NO problem ;-)

struct can_bittiming {
         __u32 bitrate;          /* Bit-rate in bits/second */
         __u32 sample_point;     /* Sample point in one-tenth of a 
percent */
         __u32 tq;               /* Time quanta (TQ) in nanoseconds */
         __u32 prop_seg;         /* Propagation segment in TQs */
         __u32 phase_seg1;       /* Phase buffer segment 1 in TQs */
         __u32 phase_seg2;       /* Phase buffer segment 2 in TQs */
         __u32 sjw;              /* Synchronisation jump width in TQs */
         __u32 brp;              /* Bit-rate prescaler */
};

So we have two of these: One for the arbitration bitrate and one 
sample_point for the data bitrate -> the 'secondary' SP -> SSP

:-)

We already have this 'dsample-point' implemented in the ip tool:

$ ip link set vcan0 type can help
Usage: ip link set DEVICE type can
	[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] |
	[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1
  	  phase-seg2 PHASE-SEG2 [ sjw SJW ] ]

	[ dbitrate BITRATE [ dsample-point SAMPLE-POINT] ] |  <<-- here!
	[ dtq TQ dprop-seg PROP_SEG dphase-seg1 PHASE-SEG1
  	  dphase-seg2 PHASE-SEG2 [ dsjw SJW ] ]

But AFAIK m_can is not using that value in m_can_set_bittiming().

>>> If good default values are transceiver and board specific, they can go
>>> into the DT. We need a generic (this means driver agnostic) binding for
>>> this. If this table needs to be tweaked for special purpose, then we can
>>> add a netlink interface for this as well. >
>>> Comments?
>>
>> By now we calculate reasonable default values (e.g. for SP and SJW), you
>> can override by setting alternative values via netlink configuration.
>>
>> I would tend to stay on this approach and not hide these things in DTs -
>> just because of someone wants to initialize his specific interface 'easier'.
> 
> If the values are not board specific, then it makes no sense to put them
> into the DT.

When they are NOT(?) board specific?

Thinking about non-SoC CAN adapters with PCI and USB pushing the SSP to 
the DT looks wrong to me.

Best,
Oliver
