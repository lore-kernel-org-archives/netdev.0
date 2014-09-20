From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Fri, 19 Sep 2014 20:41:16 -0700
Message-ID: <541CF75C.9030209@cumulusnetworks.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion>
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
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:54460 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbaITDl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 23:41:28 -0400
In-Reply-To: <20140919154946.GH1980@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/19/14, 8:49 AM, Jiri Pirko wrote:
> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com wrote:
>> On 09/19/14 09:49, Jiri Pirko wrote:
>>> This patch exposes switchdev API using generic Netlink.
>>> Example userspace utility is here:
>>> https://github.com/jpirko/switchdev
>>>
>> Is this just a temporary test tool? Otherwise i dont see reason
>> for its existence (or the API that it feeds on).
> Please read the conversation I had with Pravin and Jesse in v1 thread.
> Long story short they like to have the api separated from ovs datapath
> so ovs daemon can use it to directly communicate with driver. Also John
> Fastabend requested a way to work with driver flows without using ovs ->
> that was the original reason I created switchdev genl api.
>
> Regarding the "sw" tool, yes it is for testing purposes now. ovs daemon
> will use directly switchdev genl api.
>
> I hope I cleared this out.
We already have all the needed rtnetlink kernel api and userspace tools 
around it to support all
switching asic features. ie, the rtnetlink api is the switchdev api. We 
can do l2, l3, acl's with it.
Its unclear to me why we need another new netlink api. Which will mean 
none of the existing tools to
create bridges etc will work on a switchdev.
Which seems like going in the direction exactly opposite to what we had 
discussed earlier.

If a non-ovs flow interface is needed from userspace, we can extend the 
existing interface to include flows.
I don't understand why we should replace the existing rtnetlink 
switchdev api to accommodate flows.

Thanks,
Roopa
