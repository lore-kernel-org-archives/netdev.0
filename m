From: Julien Gomes <julien@arista.com>
Subject: Re: [PATCH net-next 2/3] ipmr: add netlink notifications on igmpmsg
 cache reports
Date: Wed, 14 Jun 2017 14:08:18 -0700
Message-ID: <3390ae4f-53ab-2ec3-5e5c-20b3fc05de4f@arista.com>
References: <20170613170822.16310-1-julien@arista.com>
 <20170613170822.16310-3-julien@arista.com>
 <e1e0c9fc-a2c7-dc98-0255-4af5c69c8e9c@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        nikolay@cumulusnetworks.com
To: nicolas.dichtel@6wind.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e1e0c9fc-a2c7-dc98-0255-4af5c69c8e9c@6wind.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2017 12:56 AM, Nicolas Dichtel wrote:
> Le 13/06/2017 à 19:08, Julien Gomes a écrit :
>> Add Netlink notifications on cache reports in ipmr, in addition to the
>> existing igmpmsg sent to mroute_sk.
>> Send RTM_NEWCACHEREPORT notifications to RTNLGRP_IPV4_MROUTE.
>>
>> MSGTYPE, VIF_ID, SRC_ADDR and DST_ADDR Netlink attributes contain the
>> same data as their equivalent fields in the igmpmsg header.
>> PKT attribute is the packet sent to mroute_sk, without the added igmpmsg
>> header.
>>
>> Suggested-by: Ryan Halbrook <halbrook@arista.com>
>> Signed-off-by: Julien Gomes <julien@arista.com>
>> ---
>>  include/uapi/linux/mroute.h | 11 ++++++++
>>  net/ipv4/ipmr.c             | 63 +++++++++++++++++++++++++++++++++++++++++++--
>>  2 files changed, 72 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
>> index f904367c0cee..f6f9e01ee734 100644
>> --- a/include/uapi/linux/mroute.h
>> +++ b/include/uapi/linux/mroute.h
>> @@ -152,6 +152,17 @@ enum {
>>  };
>>  #define IPMRA_VIFA_MAX (__IPMRA_VIFA_MAX - 1)
>>  
>> +/* ipmr netlink cache report attributes */
>> +enum {
> IPMRA_CACHEREPORTA_UNSPEC is missing.

Indeed, I will add it.

> By the way, maybe something shorter than IPMRA_CACHEREPORTA_ would be better.
> What about IPMR_CREPORTA_? IPMR_CACHEA_? IPMR_IGMPA_? or whatever.

I see absolutely no issue in shortening them.
IPMRA_CREPORT_ sounds good to me.

> What is the signification of the two 'A'? One for 'attribute', but the other?

Now that you mention it, the second 'A' is simply redundant.
I will remove it and go with IPMRA_CREPORT_.

-- 
Julien Gomes
