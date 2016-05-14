From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/4] netdevice: add SW statistics ndo
Date: Sat, 14 May 2016 14:49:17 +0200
Message-ID: <20160514124917.GA1957@nanopsycho.orion>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
 <1463053730-14991-2-git-send-email-jiri@resnulli.us>
 <5734F130.3050303@cumulusnetworks.com>
 <20160513060348.GA2060@nanopsycho.orion>
 <57362154.8040500@cumulusnetworks.com>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35736 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbcENMtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 08:49:20 -0400
Received: by mail-wm0-f65.google.com with SMTP id e201so8752760wme.2
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 05:49:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57362154.8040500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 13, 2016 at 08:47:48PM CEST, roopa@cumulusnetworks.com wrote:
>On 5/12/16, 11:03 PM, Jiri Pirko wrote:
>> Thu, May 12, 2016 at 11:10:08PM CEST, roopa@cumulusnetworks.com wrote:
>>> On 5/12/16, 4:48 AM, Jiri Pirko wrote:
>>>> From: Nogah Frankel <nogahf@mellanox.com>
>>>>
>>>> Till now we had a ndo statistics function that returned SW statistics.
>>>> We want to change the "basic" statistics to return HW statistics if
>>>> available.
>>>> In this case we need to expose a new ndo to return the SW statistics.
>>>> Add a new ndo declaration to get SW statistics
>>>> Add a function that gets SW statistics if a competible ndo exist
>>>>
>>>> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>>>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>> ---
>>>>
>>> To me netdev stats is  combined 'SW + HW' stats for that netdev.
>>> ndo_get_stats64 callback into the drivers does the magic of adding HW stats
>>> to SW (netdev) stats and returning (see enic_get_stats). HW stats is available for netdevs
>>> that are offloaded or are backed by hardware. SW stats is the stats that the driver maintains
>>> (logical or physical). HW stats is queried and added to the SW stats.
>> I'm not sure I follow. HW stats already contain SW stats. Because on
>> slow path every packet that is not offloaded and goes through kernel is
>> counted into HW stats as well (because it goes through HW port). 
>yes, correct... we don't want to double count those. But since these stats are
>generally queried from hw, I am calling them HW stats.
>you will not really maintain a software counter for this. But, the driver can maintain its own
> counters for rx and tx errors etc and I call these SW stats. They are counted at the driver.
>
>> If you
>> do HW stats + SW stats, what you get makes no sense. Am I missing something?
>If you go by my definition of HW and SW stats above, on a ndo_get_stats64() call,
>you will add the SW counters + HW counters and return. In my definition, the pkts
>that was rx'ed or tx'ed successfully are always in the HW count.
>
>> Btw, looking at enic_get_stats, looks exactly what we introduce for
>> mlxsw in this patchset.
>
>In enic_get_stats, the ones counted in software are the ones taken from 'enic->'
>     net_stats->rx_over_errors = enic->rq_truncated_pkts;
>     net_stats->rx_crc_errors = enic->rq_bad_fcs;
>
>>
>> With this patchset, we only allow user to se the actual stats for
>> slow-path aka SW stats.
>hmm...ok. But i am not sure how many will use this new attribute.
>When you do 'ip -s link show' you really want all counters on that port
>hardware or software does not matter at that point.
>
>My suggestion to move this to ethtool like attribute is because that is an existing
> way to break down your stats which ever way you want. And the best part is it can be
>customized (say rx_pkts_cpu_saw)

I bevieve that ethtool is really not a place to expose sw stats. Does
not make sense.
