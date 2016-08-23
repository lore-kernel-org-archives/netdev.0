From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v6_repost 2/3] net: core: add SW stats to
 if_stats_msg
Date: Tue, 23 Aug 2016 08:53:18 +0200
Message-ID: <20160823065318.GA1975@nanopsycho>
References: <1471612650-4508-1-git-send-email-jiri@resnulli.us>
 <1471612650-4508-3-git-send-email-jiri@resnulli.us>
 <57BBE47D.3060805@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34449 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752760AbcHWHyb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 03:54:31 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so16869114wma.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 00:54:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57BBE47D.3060805@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 23, 2016 at 07:51:57AM CEST, roopa@cumulusnetworks.com wrote:
>On 8/19/16, 6:17 AM, Jiri Pirko wrote:
>> From: Nogah Frankel <nogahf@mellanox.com>
>>
>> Add a nested attribute of SW stats to if_stats_msg
>> under IFLA_STATS_LINK_SW_64.
>>
>> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/uapi/linux/if_link.h |  1 +
>>  net/core/rtnetlink.c         | 21 +++++++++++++++++++++
>>  2 files changed, 22 insertions(+)
>>
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index a1b5202..1c9b808 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -825,6 +825,7 @@ enum {
>>  	IFLA_STATS_LINK_64,
>>  	IFLA_STATS_LINK_XSTATS,
>>  	IFLA_STATS_LINK_XSTATS_SLAVE,
>> +	IFLA_STATS_LINK_SW_64,
>>  
>hate to sound like a broken record here...
>
>sorry, but like I have been saying throughout this patch series,
>i don't think I can ack a new attribute for so called 'software stats' at the
>same level as existing IFLA_STATS_LINK_64. It just adds ambiguity for existing stats and
>confusion for future stats.
>
>Today's IFLA_STATS64 or IFLA_STATS_LINK_64 provides aggregate stats
>and historically its been 'HW only' or 'SW only' or 'HW + SW'. It depends on the driver. logical devices
>provide pure 'SW only' stats here. There is no real reason to qualify them now. The user/app
>has only cared about and will continue to care about only aggregate stats. That requirement
>has never changed.
>
>Everything else is breakdown for debug-ability.., hence should be in this second bucket I
>have been talking about (these are traditionally available via ethtool today).
>
>I am not arguing against the value of the stats this patch series provides. But, since the beginning
>of the stats api, I have always talked about a nested extensible attribute for drivers who wish to
>break their stats down. so, I have only been requesting to put this so called 'software stats' attribute
>in a new nested attribute which can be extended for other such specially qualified stats.
>
>And, I thought we had agreed on such an attribute. I mention such a nested attribute
>here again on your previous post: http://marc.info/?l=linux-netdev&m=147085641703885&w=2

And Nogah replied.

Anyway I think that next level of nesting is not necessary. On
contrary, it is wrong. The current level is extensible, mixed and
flagged already. I don't see any reason why not to add whatever kind of
stats here. What makes IFLA_STATS_LINK_SW_64 or for example
IFLA_STATS_LINK_HW_ACL so special it has to be nested in some other
attr? I would understand it it would be values of one family, but that
is not the case.
