From: Andrei Pistirica <andrei.pistirica@microchip.com>
Subject: Re: [RFC PATCH v2 1/2] macb: Add 1588 support in Cadence GEM.
Date: Wed, 23 Nov 2016 14:36:55 +0100
Message-ID: <90432c85-871f-22be-bde2-51e321828c9a@microchip.com>
References: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
 <20161120193720.GA7874@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
        <nicolas.ferre@atmel.com>, <harinikatakamlinux@gmail.com>,
        <harini.katakam@xilinx.com>, <punnaia@xilinx.com>,
        <michals@xilinx.com>, <anirudh@xilinx.com>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>, <tbultel@pixelsurmer.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161120193720.GA7874@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 20.11.2016 20:37, Richard Cochran wrote:
> On Fri, Nov 18, 2016 at 03:21:51PM +0100, Andrei Pistirica wrote:
>> +#ifdef CONFIG_MACB_USE_HWSTAMP
>> +void macb_ptp_init(struct net_device *ndev);
>> +#else
>> +void macb_ptp_init(struct net_device *ndev) { }
>
> static inline ^^^

I can do static inline only when PTP is not enabled (on else branch), 
thus the empty function is defined in the header file (since the init 
function is defined in macb_ptp and used in macb). To differentiate 
between macb versions, I'll add a wrapper.
Would this be ok?

>
>> +#endif
>
>
>> +void macb_ptp_init(struct net_device *ndev)
>> +{
>> +	struct macb *bp = netdev_priv(ndev);
>> +	struct timespec64 now;
>> +	u32 rem = 0;
>> +
>> +	if (!(bp->caps | MACB_CAPS_GEM_HAS_PTP)){
>> +		netdev_vdbg(bp->dev, "Platform does not support PTP!\n");
>> +		return;
>> +	}
>
> You would have needed '&' and not '|' here.

Yes. Another stupid mistake... sorry. I will be more careful next time.

>
> Also, using a flag limits the code to your platform.  This works for
> you, but it is short sighted.  The other MACB PTP blocks have
> different register layouts, and this patch does not lay the ground
> work for the others.
>
> The driver needs to be designed to support the other platforms.

It will support Xilinx.

>
> Thanks,
> Richard
>

Regards,
Andrei
