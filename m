From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Sat, 18 Jun 2016 09:58:56 -0400
Message-ID: <576553A0.2060504@mojatatu.com>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <20160616.172632.1759391103978744570.davem@davemloft.net>
 <20160617082411.GA1981@nanopsycho.orion>
 <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
 <20160617140512.GB1981@nanopsycho.orion> <57640F2A.7090003@mojatatu.com>
 <9f8e85ac-3e96-257e-cf7f-e7e793d41cf4@cumulusnetworks.com>
 <20160617154243.GD1981@nanopsycho.orion> <57642F76.6090403@gmail.com>
 <20160618080000.GA1989@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nogahf@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34850 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbcFRN7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 09:59:00 -0400
Received: by mail-io0-f196.google.com with SMTP id n127so13508076iof.2
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 06:58:59 -0700 (PDT)
In-Reply-To: <20160618080000.GA1989@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-18 04:00 AM, Jiri Pirko wrote:
> Fri, Jun 17, 2016 at 07:12:22PM CEST, f.fainelli@gmail.com wrote:

>>> Yep. And I believe that for offloaded forwarding, this tools should see
>>> hw counters, as they show what is going on in real.
>>
>> If your NIC is offloading packets today, these tools typically won't see
>> these stats, but ethtool -S likely will report what is going on under
>> the hood.
>>
>> Do we actually need to tell apart SW maintained from HW maintained
>> stats, or at the end all that matters is just, as DaveM pointed out,
>> getting the information, and in the case of an Ethernet switch, return
>> HW stats by default and supplement with SW stats whenever we have them,
>> all in the same namespace?
>

In general it is extremely useful for debugging to be able to see them
separately. One API to unify them (and that API being netlink) is
the way to go. I dont know if you can ever obsolete ethtool if lots
of other utils are using it - but would be nice.
It is also useful to just get the sum of them - but user space can
take care of that. David A., whatever user space tools that depended
on ethtool should now be able to retrieve them via netlink, no?

> I believe it is valuable for user to know stats for slow path
> (non-forwarded by ASIC). Also, it's just another rtnl attr. Easy.
>

So Jiri, I see:
IFLA_SW_STATS64 should that be: IFLA_HW_STATS_LINK_64?
I think IFLA_STATS_LINK_64 should continue to send s/ware stats.

cheers,
jamal
