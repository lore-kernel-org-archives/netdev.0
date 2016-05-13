From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/4] netdevice: add SW statistics ndo
Date: Fri, 13 May 2016 08:03:48 +0200
Message-ID: <20160513060348.GA2060@nanopsycho.orion>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
 <1463053730-14991-2-git-send-email-jiri@resnulli.us>
 <5734F130.3050303@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35109 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbcEMGDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 02:03:52 -0400
Received: by mail-wm0-f65.google.com with SMTP id e201so1532772wme.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 23:03:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5734F130.3050303@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 12, 2016 at 11:10:08PM CEST, roopa@cumulusnetworks.com wrote:
>On 5/12/16, 4:48 AM, Jiri Pirko wrote:
>> From: Nogah Frankel <nogahf@mellanox.com>
>>
>> Till now we had a ndo statistics function that returned SW statistics.
>> We want to change the "basic" statistics to return HW statistics if
>> available.
>> In this case we need to expose a new ndo to return the SW statistics.
>> Add a new ndo declaration to get SW statistics
>> Add a function that gets SW statistics if a competible ndo exist
>>
>> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>
>To me netdev stats is  combined 'SW + HW' stats for that netdev.
>ndo_get_stats64 callback into the drivers does the magic of adding HW stats
>to SW (netdev) stats and returning (see enic_get_stats). HW stats is available for netdevs
>that are offloaded or are backed by hardware. SW stats is the stats that the driver maintains
>(logical or physical). HW stats is queried and added to the SW stats.

I'm not sure I follow. HW stats already contain SW stats. Because on
slow path every packet that is not offloaded and goes through kernel is
counted into HW stats as well (because it goes through HW port). If you
do HW stats + SW stats, what you get makes no sense. Am I missing something?
Btw, looking at enic_get_stats, looks exactly what we introduce for
mlxsw in this patchset.

With this patchset, we only allow user to se the actual stats for
slow-path aka SW stats.


>In fact, we represent all our offloaded netdev stats following this model.
>This fits well for logical devices like vlan/bond/vxlan which are hardware offloaded too.
>
>There is HW extended stats which today are represented by ethtool
>and I had an example of a new nested attribute like IFLA_STATS_LINK_HW_EXTENDED
>to provide ethtool like extensible stats. If people want pure hardware stats, they
>get it via this. In which case I am not seeing the point in adding a new ndo and a new
>stats attribute just for this. If you are looking for pure hardware stats, any reason we cant
>just use the IFLA_STATS_LINK_HW_EXTENDED and add ethtool like hw stats ?.
>This will be one place to look for all hardware stats and will be extensible too.
>
>
