From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 3/6] net: ethernet: ti: cpts: add support of cpts
 HW_TS_PUSH
Date: Thu, 8 Dec 2016 13:04:11 -0600
Message-ID: <58eea45f-b8fe-6892-e784-b41638c62fd8@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-4-grygorii.strashko@ti.com>
 <20161203232130.GA17944@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161203232130.GA17944@netboy>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 12/03/2016 05:21 PM, Richard Cochran wrote:
> On Mon, Nov 28, 2016 at 05:04:25PM -0600, Grygorii Strashko wrote:
>> This also change overflow polling period when HW_TS_PUSH feature is
>> enabled - overflow check work will be scheduled more often (every
>> 200ms) for proper HW_TS_PUSH events reporting.
> 
> For proper reporting, you should make use of the interrupt.  The small
> fifo (16 iirc) could very well overflow in 200 ms.  The interrupt
> handler should read out the entire fifo at each interrupt.
> 

huh. Seems this is not really good idea, because MISC Irq will be 
triggered for *any* CPTS event and there is no way to enable it just for
HW_TS_PUSH. So, this doesn't work will with current code for RX/TX timestamping
(which uses polling mode). + runtime overhead in net RX/TX caused by 
triggering more interrupts. 

May be, overflow check/polling timeout can be made configurable (module parameter). 

-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
