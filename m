From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Thu, 19 Oct 2017 22:17:11 +0200
Message-ID: <6f916786-7a91-9265-7b43-635d022c61ab@hartkopp.net>
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
 <f651ffd4-826c-ee20-aebf-e3c2c1b89ecf@hartkopp.net>
 <4b53c9ff-395f-670f-b55c-38ccfb37ac30@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>,
        "Quadros, Roger" <rogerq@ti.com>
To: =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Sekhar Nori <nsekhar@ti.com>,
        Franklin S Cooper Jr <fcooper@ti.com>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, wg@grandegger.com,
        quentin.schulz@free-electrons.com, edumazet@google.com,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4b53c9ff-395f-670f-b55c-38ccfb37ac30@gmx.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2017 09:54 PM, Mario Hüttel wrote:
> On 10/19/2017 08:35 PM, Oliver Hartkopp wrote:

>> We already have this 'dsample-point' implemented in the ip tool:
>>
>> $ ip link set vcan0 type can help
>> Usage: ip link set DEVICE type can
>>      [ bitrate BITRATE [ sample-point SAMPLE-POINT] ] |
>>      [ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1
>>         phase-seg2 PHASE-SEG2 [ sjw SJW ] ]
>>
>>      [ dbitrate BITRATE [ dsample-point SAMPLE-POINT] ] |  <<-- here!
>>      [ dtq TQ dprop-seg PROP_SEG dphase-seg1 PHASE-SEG1
>>         dphase-seg2 PHASE-SEG2 [ dsjw SJW ] ]
>>
>> But AFAIK m_can is not using that value in m_can_set_bittiming().
>>
> Actually I need some clarification. The sample point of the can core is
> between the two time segments.
> I always thought that the "sample point" options of the ip tool are used
> in the internal
> calculation of the two timing segments and is therefore no individual value.

You are right.

See picture at http://www.bittiming.can-wiki.info/

Usually you can give the bitrate and the sample point (which is at 75% 
aka 0.750 by default) and then the kernel-internal bitrate calculating 
algorithm calculates the tq prop-seg phase-seg1 phase-seg2 stuff.

Alternatively you can provide the tq prop-seg phase-seg1 phase-seg2 
stuff on your own which is set to the CAN controller registers then.

For that reason my remark "m_can is not using that value" was wrong as 
m_can just uses the tq prop-seg phase-seg1 phase-seg2 stuff - either 
from the bitrate calculation or provided by the user.

Thanks for the question ;-)

Best,
Oliver
