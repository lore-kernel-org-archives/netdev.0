From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Fri, 19 Sep 2014 22:39:51 -0700
Message-ID: <541D1327.4080905@gmail.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion> <541C6E6D.9000109@mojatatu.com> <541CAA3C.5080105@intel.com> <541CAB9A.3040100@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:37520 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbaITFj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 01:39:56 -0400
Received: by mail-oi0-f47.google.com with SMTP id e131so2116527oig.6
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 22:39:55 -0700 (PDT)
In-Reply-To: <541CAB9A.3040100@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/14 15:18, Jamal Hadi Salim wrote:
> On 09/19/14 18:12, John Fastabend wrote:
>> On 09/19/2014 10:57 AM, Jamal Hadi Salim wrote:
>>> On 09/19/14 11:49, Jiri Pirko wrote:
>>>> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com wrote:
>>>
>>>>> Is this just a temporary test tool? Otherwise i dont see reason
>>>>> for its existence (or the API that it feeds on).
>>>>
>>>> Please read the conversation I had with Pravin and Jesse in v1 thread.
>>>> Long story short they like to have the api separated from ovs datapath
>>>> so ovs daemon can use it to directly communicate with driver. Also John
>>>> Fastabend requested a way to work with driver flows without using
>>>> ovs ->
>>>> that was the original reason I created switchdev genl api.
>>>>
>>>> Regarding the "sw" tool, yes it is for testing purposes now. ovs daemon
>>>> will use directly switchdev genl api.
>>>>
>>>> I hope I cleared this out.
>>>>
>>>
>>> It is - thanks Jiri.
>>>
>>> cheers,
>>> jamal
>>
>> Hi Jiri,
>>
>> I was considering a slightly different approach where the
>> device would report via netlink the fields/actions it
>> supported rather than creating pre-defined enums for every
>> possible key.
>>
>> I already need to have an API to report fields/matches
>> that are being supported why not have the device report
>> the headers as header fields (len, offset) and the
>> associated parse graph the hardware uses? Vendors should
>> have this already to describe/design their real hardware.
>>
>> As always its better to have code and when I get some
>> time I'll try to write it up. Maybe its just a separate
>> classifier although I don't actually want two hardware
>> flow APIs.
>>
>> I see you dropped the RFC tag are you proposing we include
>> this now?
>>
>
>
> Actually I just realized i missed something very basic that
> Jiri said. I think i understand the tool being there for testing
> but i am assumed the same about the genlink api.
> Jiri, are you saying that genlink api is there to
> stay?

So, I really have mixed feelings about this netlink API, in particular 
because it is not clear to me where is the line between what should be a 
network device ndo operation, what should be an ethtool command, what 
should be a netlink message, and the rest.

I can certainly acknowledge the fact that manipulating flows is not 
ideal with the current set of tools, but really once we are there with 
netlink, how far are we from not having any network devices at all, and 
how does that differ from OpenWrt's swconfig in the end [1]?

[1]: https://lwn.net/Articles/571390/
--
Florian
