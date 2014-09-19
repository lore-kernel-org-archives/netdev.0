From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Fri, 19 Sep 2014 15:12:12 -0700
Message-ID: <541CAA3C.5080105@intel.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion> <541C6E6D.9000109@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34307 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757837AbaISWMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 18:12:13 -0400
In-Reply-To: <541C6E6D.9000109@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 10:57 AM, Jamal Hadi Salim wrote:
> On 09/19/14 11:49, Jiri Pirko wrote:
>> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com wrote:
> 
>>> Is this just a temporary test tool? Otherwise i dont see reason
>>> for its existence (or the API that it feeds on).
>>
>> Please read the conversation I had with Pravin and Jesse in v1 thread.
>> Long story short they like to have the api separated from ovs datapath
>> so ovs daemon can use it to directly communicate with driver. Also John
>> Fastabend requested a way to work with driver flows without using ovs ->
>> that was the original reason I created switchdev genl api.
>>
>> Regarding the "sw" tool, yes it is for testing purposes now. ovs daemon
>> will use directly switchdev genl api.
>>
>> I hope I cleared this out.
>>
> 
> It is - thanks Jiri.
> 
> cheers,
> jamal

Hi Jiri,

I was considering a slightly different approach where the
device would report via netlink the fields/actions it
supported rather than creating pre-defined enums for every
possible key.

I already need to have an API to report fields/matches
that are being supported why not have the device report
the headers as header fields (len, offset) and the
associated parse graph the hardware uses? Vendors should
have this already to describe/design their real hardware.

As always its better to have code and when I get some
time I'll try to write it up. Maybe its just a separate
classifier although I don't actually want two hardware
flow APIs.

I see you dropped the RFC tag are you proposing we include
this now?

.John
