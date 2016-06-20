From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Sun, 19 Jun 2016 20:14:57 -0700
Message-ID: <CAJieiUhFRp6wE_gt-0q9KYQTYdEyg5yFUYa89K+ovaQr7QE5Zg@mail.gmail.com>
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
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	David Ahern <dsa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nogah Frankel <nogahf@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>, sd@queasysnail.net,
	eranbe@mellanox.com, Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:36014 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbcFTDPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 23:15:24 -0400
Received: by mail-vk0-f47.google.com with SMTP id u64so180011308vkf.3
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 20:14:58 -0700 (PDT)
In-Reply-To: <57642F76.6090403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 10:12 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 06/17/2016 08:42 AM, Jiri Pirko wrote:
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
> If your NIC is offloading packets today, these tools typically won't see
> these stats, but ethtool -S likely will report what is going on under
> the hood.
>
> Do we actually need to tell apart SW maintained from HW maintained
> stats, or at the end all that matters is just, as DaveM pointed out,
> getting the information, and in the case of an Ethernet switch, return
> HW stats by default and supplement with SW stats whenever we have them,
> all in the same namespace?
> --

I have also mentioned this before, the default api must provide
accumulated (hw and sw) stats...,
because this is the api that the user queries on an interface.
For advanced debugging, people do want a break down and thats what
traditionally ethtool has provided
and the new stats api should eventually include support for ethtool like stats.
