From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V1 4/4] can: m_can: allow to send std frame on CAN FD
 mode
Date: Wed, 05 Nov 2014 12:08:21 +0100
Message-ID: <545A0525.107@hartkopp.net>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com> <1415174326-6623-4-git-send-email-b29396@freescale.com> <5459FEDE.9050405@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5459FEDE.9050405@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05.11.2014 11:41, Marc Kleine-Budde wrote:
> On 11/05/2014 08:58 AM, Dong Aisheng wrote:
>> The current code sends all CAN frames on CAN FD format(with BRS or not)
>> if CAN_CTRLMODE_FD is enabled.
>> However, even CAN_CTRLMODE_FD is enabled, the can tool may still
>> send normal frames.
>> e.g.
>> ip link set can0 up type can bitrate 1000000 dbitrate 1000000 fd on
>> cansend can0 123#112233
>>
>> Therefore sending normal CAN frame on FD format seems not reasonable
>> and the CAN FD incapable device may not be able to receive it correctly.
>>
>> The patch switches the M_CAN operation mode to ISO11898-1 instead of
>> staying on CAN FD operation mode by writing "11" to CMR bit if find
>> we're sending a normal can skb.
>
> With this patch applied and Olivre's version of 3/4, how does the
> application send CAN-FD frames?

This patch becomes obsolete when we do it like in my answer of [3/4].

> 1. witch on CAN-FD via "ip fd on"

With

ip link set can0 type can fd on

the netdevice switches to the MTU of CAN FD (72) instead of 16.

This means that this netdevice can handle CAN frames (MTU 16) and CAN FD 
frames (MTU 72).

When you send a standard CAN frame, e.g.

	cansend can0 123#112233

you would get a CAN 2.0 frame (dlc = 3) on the bus.

When you send a CAN FD frame, e.g.

	cansend can0 123##0112233

you would get a CAN FD frame (dlc = 3) on the bus.

With

	cansend can0 123##1112233

you would get a CAN FD frame (dlc = 3) with BRS on the bus.

Whether it is CAN or CAN FD is given by checking skb->len for CAN_MTU of 
CANFD_MTU in the driver.

Regards,
Oliver


> 2. write a struct canfd_frame
>
> Correct?
>
> What happens if:
> 3. write a struct can_frame
>
> A CAN frame is send?
>
> Oliver are you okay with this behaviour?
>
> Marc
>
