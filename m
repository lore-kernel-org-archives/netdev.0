From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Thu, 19 Oct 2017 13:14:55 +0200
Message-ID: <a972cec1-3386-3ca3-ace3-175e1cabd286@hartkopp.net>
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
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.162]:32450 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752108AbdJSLPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:15:09 -0400
In-Reply-To: <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2017 11:13 AM, Marc Kleine-Budde wrote:
> On 10/19/2017 07:07 AM, Sekhar Nori wrote:


>>>> Since we have a netlink socket interface to configure sample point, I
>>>> wonder if that should be extended to configure SSP too (or at least the
>>>> offset part of SSP)?

+1 too

>>>
>>> Sekhar is right that ideally the user should be able to set the SSP at
>>> runtime. However, my issue is that based on my experience CAN users
>>> expect the driver to just work the majority of times. For unique use
>>> cases where the driver calculated values don't work then the user should
>>> be able to override it. This should only be done for a very small
>>> percentage of CAN users. Unless you allow DT to provide a default SSP
>>> many users of MCAN may find that the default SSP doesn't work and must
>>> always use runtime overrides to get anything to work. I don't think that
>>> is a good user experience which is why I don't like the idea.
>>
>> Fair enough. But not quite sure if CAN users expect CAN-FD to "just
>> work" without doing any bittiming related setup.
> 
>  From my point of view I'd rather buy a board from a HW vendor where
> CAN-FD works, rather than a board where I have to tweak the bit-timing
> for a simple CAN-FD test setup.
> 
> As far as I see for the m_can driver it's a single tuple: "bitrate > 2.5
> MBit/s -> 50%". Do we need an array of tuples in general?
> 
> If good default values are transceiver and board specific, they can go
> into the DT. We need a generic (this means driver agnostic) binding for
> this. If this table needs to be tweaked for special purpose, then we can
> add a netlink interface for this as well. >
> Comments?

By now we calculate reasonable default values (e.g. for SP and SJW), you 
can override by setting alternative values via netlink configuration.

I would tend to stay on this approach and not hide these things in DTs - 
just because of someone wants to initialize his specific interface 'easier'.

One tool, one place is IMHO still the best option.

Regards,
Oliver
