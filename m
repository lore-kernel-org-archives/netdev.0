From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 05:39:57 -0700
Message-ID: <541D759D.3030000@cumulusnetworks.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion> <541CF75C.9030209@cumulusnetworks.com> <20140920080943.GD1821@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, dev@openvswitch.org,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@intel.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:51635 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110AbaITMkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 08:40:07 -0400
In-Reply-To: <20140920080943.GD1821@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/14, 1:09 AM, Jiri Pirko wrote:
> Sat, Sep 20, 2014 at 05:41:16AM CEST, roopa@cumulusnetworks.com wrote:
>> On 9/19/14, 8:49 AM, Jiri Pirko wrote:
>>> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com wrote:
>>>> On 09/19/14 09:49, Jiri Pirko wrote:
>>>>> This patch exposes switchdev API using generic Netlink.
>>>>> Example userspace utility is here:
>>>>> https://github.com/jpirko/switchdev
>>>>>
>>>> Is this just a temporary test tool? Otherwise i dont see reason
>>>> for its existence (or the API that it feeds on).
>>> Please read the conversation I had with Pravin and Jesse in v1 thread.
>>> Long story short they like to have the api separated from ovs datapath
>>> so ovs daemon can use it to directly communicate with driver. Also John
>>> Fastabend requested a way to work with driver flows without using ovs ->
>>> that was the original reason I created switchdev genl api.
>>>
>>> Regarding the "sw" tool, yes it is for testing purposes now. ovs daemon
>>> will use directly switchdev genl api.
>>>
>>> I hope I cleared this out.
>> We already have all the needed rtnetlink kernel api and userspace tools
>> around it to support all
>> switching asic features. ie, the rtnetlink api is the switchdev api. We can
>> do l2, l3, acl's with it.
>> Its unclear to me why we need another new netlink api. Which will mean none
>> of the existing tools to
>> create bridges etc will work on a switchdev.
> No one is proposing such API. Note that what I'm trying to solve in my
> patchset is FLOW world. There is only one API there, ovs genl. But the
> usage of that for hw offload purposes was nacked by ovs maintainer. Plus
> couple of people wanted to run the offloading independently on ovs
> instance. Therefore I introduced the switchdev genl, which takes care of
> that. No plan to extend it for other things you mentioned, just flows.
ok, That was not clear to me. Introducing a new genl api and calling it the
switchd dev api can result it non-flow creep into it in the future.
>
>
>> Which seems like going in the direction exactly opposite to what we had
>> discussed earlier.
> Nope. The previous discussion ignored flows.
>> If a non-ovs flow interface is needed from userspace, we can extend the
>> existing interface to include flows.
> How? You mean to extend rtnetlink? What advantage it would bring
> comparing to separate genl iface?
yes. Advantage would be that we dont have yet another parallel switchdev 
netlink api.


>> I don't understand why we should replace the existing rtnetlink switchdev api
>> to accommodate flows.
> Sorry, I do not undertand what "existing rtnetlink switchdev api" you
> have on mind. Would you care to explain?

I am taking about existing rtnetlink api that bridge, ip link uses to 
talk l2 and l3 to the kernel.
RTM_NEWROUTE etc.
