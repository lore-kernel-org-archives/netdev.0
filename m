From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next 1/4] netdevice: add SW statistics ndo
Date: Thu, 12 May 2016 15:23:13 -0700
Message-ID: <CAGVrzcbt+qVdE6cWqMHBi9vCXGC3kcRYMhF6yt0L-eFtq++ZSg@mail.gmail.com>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
 <1463053730-14991-2-git-send-email-jiri@resnulli.us> <5734F130.3050303@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, nogahf@mellanox.com,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	ogerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, tgraf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34542 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbcELWXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 18:23:53 -0400
Received: by mail-io0-f196.google.com with SMTP id d62so1087385iof.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 15:23:53 -0700 (PDT)
In-Reply-To: <5734F130.3050303@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-05-12 14:10 GMT-07:00 Roopa Prabhu <roopa@cumulusnetworks.com>:
> On 5/12/16, 4:48 AM, Jiri Pirko wrote:
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
> To me netdev stats is  combined 'SW + HW' stats for that netdev.
> ndo_get_stats64 callback into the drivers does the magic of adding HW stats
> to SW (netdev) stats and returning (see enic_get_stats). HW stats is available for netdevs
> that are offloaded or are backed by hardware. SW stats is the stats that the driver maintains
> (logical or physical). HW stats is queried and added to the SW stats.
> In fact, we represent all our offloaded netdev stats following this model.
> This fits well for logical devices like vlan/bond/vxlan which are hardware offloaded too.

Agreed, if you take a look at what the DSA slave network devices do in
net/dsa/slave.c they basically overload the switch-mainainted
statistics with some per-port net_device software stats. We would
probably want to do the same thing

>
> There is HW extended stats which today are represented by ethtool
> and I had an example of a new nested attribute like IFLA_STATS_LINK_HW_EXTENDED
> to provide ethtool like extensible stats. If people want pure hardware stats, they
> get it via this. In which case I am not seeing the point in adding a new ndo and a new
> stats attribute just for this. If you are looking for pure hardware stats, any reason we cant
> just use the IFLA_STATS_LINK_HW_EXTENDED and add ethtool like hw stats ?.
> This will be one place to look for all hardware stats and will be extensible too.

Agreed, worste case, you format your statistics such that they reflect
they come from the HW (e.g: hw_TxOctets...)
-- 
Florian
