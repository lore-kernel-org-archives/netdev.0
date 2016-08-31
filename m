From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Wed, 31 Aug 2016 12:15:10 -0700
Message-ID: <60d13549-f9ea-694b-1030-0c610e0d9722@gmail.com>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <CAKoUAr=Z56VxzW=zHu7r9ossdXHQ6xpeYdR5jwhv38zkV_eKFQ@mail.gmail.com>
 <57C1FB42.104@codeaurora.org> <57C728B4.7070303@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, devicetree@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
        shankerd@codeaurora.org, vikrams@codeaurora.org,
        cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
        andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
        jcm@redhat.com, agross@codeaurora.org,
        David Miller <davem@davemloft.net>, LinoSanfilippo@gmx.de
To: Timur Tabi <timur@codeaurora.org>,
        Rami Rosen <roszenrami@gmail.com>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57C728B4.7070303@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/31/2016 11:57 AM, Timur Tabi wrote:
> Timur Tabi wrote:
>>
>>> Seems that there are several unused members in the emac_stats struct:
>>>
>>>> +struct emac_stats {
>>> ...
>>> ...
>>> Both rx_bcast_byte_cnt and rx_mcast_byte_cnt are not used anywhere/
>>>> +       u64 rx_bcast_byte_cnt;  /* broadcast packets byte count
>>>> (without FCS) */
>>>> +       u64 rx_mcast_byte_cnt;  /* multicast packets byte count
>>>> (without FCS) */
>>> ...
>>> rx_err_addr is not used
>>>> +       u64 rx_err_addr;        /* packets dropped due to address
>>>> filtering */
>>
>> I'll go through the structure and remove the unused fields.
> 
> It turns out I cannot actually strip out those "unused" fields.  They
> are all indirectly used in emac_get_stats64:
> 
>     u64 *stats_itr = &adpt->stats.rx_ok;
> 
>     while (addr <= REG_MAC_RX_STATUS_END) {
>         val = readl_relaxed(adpt->base + addr);
>         *stats_itr += val;
>         stats_itr++;
>         addr += sizeof(u32);
>     }

if these are truly 64-bits stats, how come you are using a single
readl_* to access them? Or is the u64 rx_err_addr just used as temporary
storage and aligned to the largest size you need to deal with?
-- 
Florian
