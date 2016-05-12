From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next 1/4] netdevice: add SW statistics ndo
Date: Thu, 12 May 2016 14:10:08 -0700
Message-ID: <5734F130.3050303@cumulusnetworks.com>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us> <1463053730-14991-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33957 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbcELVKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 17:10:11 -0400
Received: by mail-pa0-f44.google.com with SMTP id r5so34148188pag.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 14:10:11 -0700 (PDT)
In-Reply-To: <1463053730-14991-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/16, 4:48 AM, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
>
> Till now we had a ndo statistics function that returned SW statistics.
> We want to change the "basic" statistics to return HW statistics if
> available.
> In this case we need to expose a new ndo to return the SW statistics.
> Add a new ndo declaration to get SW statistics
> Add a function that gets SW statistics if a competible ndo exist
>
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>
To me netdev stats is  combined 'SW + HW' stats for that netdev.
ndo_get_stats64 callback into the drivers does the magic of adding HW stats
to SW (netdev) stats and returning (see enic_get_stats). HW stats is available for netdevs
that are offloaded or are backed by hardware. SW stats is the stats that the driver maintains
(logical or physical). HW stats is queried and added to the SW stats.
In fact, we represent all our offloaded netdev stats following this model.
This fits well for logical devices like vlan/bond/vxlan which are hardware offloaded too.

There is HW extended stats which today are represented by ethtool
and I had an example of a new nested attribute like IFLA_STATS_LINK_HW_EXTENDED
to provide ethtool like extensible stats. If people want pure hardware stats, they
get it via this. In which case I am not seeing the point in adding a new ndo and a new
stats attribute just for this. If you are looking for pure hardware stats, any reason we cant
just use the IFLA_STATS_LINK_HW_EXTENDED and add ethtool like hw stats ?.
This will be one place to look for all hardware stats and will be extensible too.
