From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Sat, 27 Aug 2016 15:42:42 -0500
Message-ID: <57C1FB42.104@codeaurora.org>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <CAKoUAr=Z56VxzW=zHu7r9ossdXHQ6xpeYdR5jwhv38zkV_eKFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org, bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org
To: Rami Rosen <roszenrami-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKoUAr=Z56VxzW=zHu7r9ossdXHQ6xpeYdR5jwhv38zkV_eKFQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rami Rosen wrote:
> Hi,
>
> Shouldn't it be obj-$(CONFIG_QCOM_EMAC) instead obj-y?

Yes, I noticed this soon after I posted this patch.  I will fix it in v10.

> The return type of the method emac_tx_tpd_create()  should be void, as
> it always returns true.

Will fix, thanks.

> Seems that there are several unused members in the emac_stats struct:
>
>> +struct emac_stats {
> ...
> ...
> Both rx_bcast_byte_cnt and rx_mcast_byte_cnt are not used anywhere/
>> +       u64 rx_bcast_byte_cnt;  /* broadcast packets byte count (without FCS) */
>> +       u64 rx_mcast_byte_cnt;  /* multicast packets byte count (without FCS) */
> ...
> rx_err_addr is not used
>> +       u64 rx_err_addr;        /* packets dropped due to address filtering */

I'll go through the structure and remove the unused fields.

>
> Typo: it is jabbers and not jubbers; greppping for "jubber" under
> drivers/net/ethernet gives
> 0 results, whereas:
> /net-next/drivers/net/ethernet$ grep -R jabber | wc -l
> gives 241 results.
>
>> +       u64 rx_jubbers;         /* jubbers */

Thanks.  I'll fix that in v10.

>
>
> ...
> ..
> tx_rd_eop and tx_len_err are not used
>> +       u64 tx_rd_eop;          /* count of reads beyond EOP */
>> +       u64 tx_len_err;         /* packets with length mismatch */
>
> Both tx_bcast_byte and tx_mcast_byte are not used.
>> +       u64 tx_bcast_byte;      /* broadcast packets byte count (without FCS) */
>> +       u64 tx_mcast_byte;      /* multicast packets byte count (without FCS) */
>
> Thanks for your good work, it seems that the driver is almost done!

I'm grateful for the opportunity to improve this driver over the crappy 
one that's been bouncing around internally for years, and for all the 
people who helped me along the way.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
