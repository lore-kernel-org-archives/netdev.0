From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Wed, 31 Aug 2016 13:57:56 -0500
Message-ID: <57C728B4.7070303@codeaurora.org>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <CAKoUAr=Z56VxzW=zHu7r9ossdXHQ6xpeYdR5jwhv38zkV_eKFQ@mail.gmail.com>
 <57C1FB42.104@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, devicetree@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
        shankerd@codeaurora.org, vikrams@codeaurora.org,
        cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
        andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
        jcm@redhat.com, agross@codeaurora.org,
        David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, LinoSanfilippo@gmx.de
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47758 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbcHaS6A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 14:58:00 -0400
In-Reply-To: <57C1FB42.104@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi wrote:
>
>> Seems that there are several unused members in the emac_stats struct:
>>
>>> +struct emac_stats {
>> ...
>> ...
>> Both rx_bcast_byte_cnt and rx_mcast_byte_cnt are not used anywhere/
>>> +       u64 rx_bcast_byte_cnt;  /* broadcast packets byte count
>>> (without FCS) */
>>> +       u64 rx_mcast_byte_cnt;  /* multicast packets byte count
>>> (without FCS) */
>> ...
>> rx_err_addr is not used
>>> +       u64 rx_err_addr;        /* packets dropped due to address
>>> filtering */
>
> I'll go through the structure and remove the unused fields.

It turns out I cannot actually strip out those "unused" fields.  They 
are all indirectly used in emac_get_stats64:

	u64 *stats_itr = &adpt->stats.rx_ok;

	while (addr <= REG_MAC_RX_STATUS_END) {
		val = readl_relaxed(adpt->base + addr);
		*stats_itr += val;
		stats_itr++;
		addr += sizeof(u32);
	}

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
