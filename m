From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Mon, 30 Nov 2015 15:13:22 +0100
Message-ID: <CAPv3WKcHnJHCvg63Vs79RboNOuESU8jCLouKPRW4NdptAd_hag@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<5655FF36.20202@gmail.com>
	<CAPv3WKc4zSmjtw_FeePCVCaq_aUubbCw_ggtxgxs0-7LwL7fHQ@mail.gmail.com>
	<20151129.210210.1777978635596463961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Yair Mahalalel <myair@marvell.com>,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Evan Wang <xswang@marvell.com>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>, nitroshift@yahoo.com,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36027 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754332AbbK3ONX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 09:13:23 -0500
Received: by obdgf3 with SMTP id gf3so128869344obd.3
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 06:13:22 -0800 (PST)
In-Reply-To: <20151129.210210.1777978635596463961.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David and Florian,

2015-11-30 3:02 GMT+01:00 David Miller <davem@davemloft.net>:
> From: Marcin Wojtas <mw@semihalf.com>
> Date: Sun, 29 Nov 2015 14:21:35 +0100
>
>>> Looking at your patches, it was not entirely clear to me how the buffer
>>> manager on these Marvell SoCs work, but other networking products have
>>> something similar, like Broadcom's Cable Modem SoCs (BCM33xx) FPM, and
>>> maybe Freescale's FMAN/DPAA seems to do something similar.
>>>
>>> Does the buffer manager allocation work by giving you a reference/token
>>> to a buffer as opposed to its address? If that is the case, it would be
>>> good to design support for such hardware in a way that it can be used by
>>> more drivers.
>>
>> It does not operate on a reference/token but buffer pointers (physical
>> adresses). It's a ring and you cannot control which buffer will be
>> taken at given moment.
>
> He understands this, he's asking you to make an "abstraction".

I assumed that Florian is not familiar with how the HW works,
otherwise why did he ask about the details of operation and the buffer
representation in ring (token vs. address)? Nevertheless, let's talk
about the "abstraction" itself.

>
> FWIW, I know of at least one more chip that operates this way too and
> the code I wrote for it, particularly the buffer management, took a
> while to solidify.  Common helpers for this kind of situation would
> have helped me back when I wrote it.

What kind of abstraction and helpers do you mean? Some kind of API
(e.g. bm_alloc_buffer, bm_initialize_ring bm_put_buffer,
bm_get_buffer), which would be used by platform drivers (and specific
aplications if one wants to develop on top of the kernel)?

In general, what is your top-view of such solution and its cooperation
with the drivers?

I'm also wondering how to satisfy different types of HW. For example
buffer managers used by mvneta and mvpp2 are similar, but the major
difference is the way of accessing the buffers (via SRAM in mvneta vs
indirectly via registers in mvpp2) - do you think some kind of
callbacks is a solution, also with other vendors taken into
consideration?

Best regards,
Marcin
