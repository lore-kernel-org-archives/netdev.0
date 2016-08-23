From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v6_repost 2/3] net: core: add SW stats to if_stats_msg
Date: Mon, 22 Aug 2016 22:51:57 -0700
Message-ID: <57BBE47D.3060805@cumulusnetworks.com>
References: <1471612650-4508-1-git-send-email-jiri@resnulli.us> <1471612650-4508-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35734 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756227AbcHWFwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 01:52:02 -0400
Received: by mail-pf0-f178.google.com with SMTP id x72so40060788pfd.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 22:52:00 -0700 (PDT)
In-Reply-To: <1471612650-4508-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/19/16, 6:17 AM, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
>
> Add a nested attribute of SW stats to if_stats_msg
> under IFLA_STATS_LINK_SW_64.
>
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/uapi/linux/if_link.h |  1 +
>  net/core/rtnetlink.c         | 21 +++++++++++++++++++++
>  2 files changed, 22 insertions(+)
>
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index a1b5202..1c9b808 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -825,6 +825,7 @@ enum {
>  	IFLA_STATS_LINK_64,
>  	IFLA_STATS_LINK_XSTATS,
>  	IFLA_STATS_LINK_XSTATS_SLAVE,
> +	IFLA_STATS_LINK_SW_64,
>  
hate to sound like a broken record here...

sorry, but like I have been saying throughout this patch series,
i don't think I can ack a new attribute for so called 'software stats' at the
same level as existing IFLA_STATS_LINK_64. It just adds ambiguity for existing stats and
confusion for future stats.

Today's IFLA_STATS64 or IFLA_STATS_LINK_64 provides aggregate stats
and historically its been 'HW only' or 'SW only' or 'HW + SW'. It depends on the driver. logical devices
provide pure 'SW only' stats here. There is no real reason to qualify them now. The user/app
has only cared about and will continue to care about only aggregate stats. That requirement
has never changed.

Everything else is breakdown for debug-ability.., hence should be in this second bucket I
have been talking about (these are traditionally available via ethtool today).

I am not arguing against the value of the stats this patch series provides. But, since the beginning
of the stats api, I have always talked about a nested extensible attribute for drivers who wish to
break their stats down. so, I have only been requesting to put this so called 'software stats' attribute
in a new nested attribute which can be extended for other such specially qualified stats.

And, I thought we had agreed on such an attribute. I mention such a nested attribute
here again on your previous post: http://marc.info/?l=linux-netdev&m=147085641703885&w=2

Thanks,
Roopa
