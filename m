From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Sat, 18 Jun 2016 10:00:00 +0200
Message-ID: <20160618080000.GA1989@nanopsycho.orion>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <20160616.172632.1759391103978744570.davem@davemloft.net>
 <20160617082411.GA1981@nanopsycho.orion>
 <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
 <20160617140512.GB1981@nanopsycho.orion>
 <57640F2A.7090003@mojatatu.com>
 <9f8e85ac-3e96-257e-cf7f-e7e793d41cf4@cumulusnetworks.com>
 <20160617154243.GD1981@nanopsycho.orion>
 <57642F76.6090403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nogahf@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33508 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbcFRIAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 04:00:03 -0400
Received: by mail-wm0-f66.google.com with SMTP id r201so2564946wme.0
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 01:00:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57642F76.6090403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 17, 2016 at 07:12:22PM CEST, f.fainelli@gmail.com wrote:
>On 06/17/2016 08:42 AM, Jiri Pirko wrote:
>> Fri, Jun 17, 2016 at 05:35:53PM CEST, dsa@cumulusnetworks.com wrote:
>>> On 6/17/16 8:54 AM, Jamal Hadi Salim wrote:
>>>> On 16-06-17 10:05 AM, Jiri Pirko wrote:
>>>>> Fri, Jun 17, 2016 at 03:48:35PM CEST, dsa@cumulusnetworks.com wrote:
>>>>>> On 6/17/16 2:24 AM, Jiri Pirko wrote:
>>>>>>>
>>>>
>>>>>
>>>>> That is problematic. Existing apps depend on rtnetlink stats. But if we
>>>>> don't count offloaded forwarded packets, the apps don't see anything.
>>>>> Therefore I believe that this patchset approach is better. The existing
>>>>> apps continue to work and future apps can use newly introduces sw_stats
>>>>> to query slowpath traffic. Makes sense to me.
>>>>>
>>>>
>>>> I agree with Jiri. It is a bad idea to depend on ethtool for any of
>>>> this stuff. Is there a way we can tag netlink stats instead
>>>> to indicate they are hardware or software?
>>>
>>> Right, old API but the key here is that low level h/w stats are returned by a
>>> different API.
>>>
>>> By default ip, ifconfig, snmpd, etc all continue to get traditional S/W stats
>>> - counters as seen by the CPU.
>> 
>> Yep. And I believe that for offloaded forwarding, this tools should see
>> hw counters, as they show what is going on in real.
>
>If your NIC is offloading packets today, these tools typically won't see
>these stats, but ethtool -S likely will report what is going on under
>the hood.
>
>Do we actually need to tell apart SW maintained from HW maintained
>stats, or at the end all that matters is just, as DaveM pointed out,
>getting the information, and in the case of an Ethernet switch, return
>HW stats by default and supplement with SW stats whenever we have them,
>all in the same namespace?

I believe it is valuable for user to know stats for slow path
(non-forwarded by ASIC). Also, it's just another rtnl attr. Easy.
