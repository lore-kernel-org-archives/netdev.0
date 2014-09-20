From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 12:01:21 +0100
Message-ID: <20140920110121.GB29419@casper.infradead.org>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
 <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
 <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com>
 <541CAA3C.5080105@intel.com>
 <541CAB9A.3040100@mojatatu.com>
 <20140920081702.GF1821@nanopsycho.orion>
 <541D54BA.6070709@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45661 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaITLBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 07:01:24 -0400
Content-Disposition: inline
In-Reply-To: <541D54BA.6070709@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/14 at 06:19am, Jamal Hadi Salim wrote:
> The ovs guys are against this and now no *api exists*?
> Write a 15 tuple classifier tc classifier and use it. I will be more
> than happy to help you. I will get to it when we have basics L2 working
> on real devices.

Nothing speaks against having such a tc classifier. In fact, having
the interface consist of only an embedded Netlink attribute structure
would allow for such a classifier in a very straight forward way.

That doesn't mean everybody should be forced to use the stateful
tc interface.

> Totally unacceptable in my books. If the OVS guys want some way out
> to be able to ride on some vendor sdks then that is their problem.
> We shouldnt allow for such loopholes. This is why/how TOE never made it
> in the kernel.

No need for false accusations here. Nobody ever mentioned vendor SDKs.

The statement was that the requirement of deriving hardware flows from
software flows *in the kernel* is not flexible enough for the future
for reasons such as:

1) The OVS software data path might be based on eBPF in the future and
   it is unclear how we could derive hardware flows from that
   transparently.

2) Depending on hardware capabilities. Hardware flows might need to be
   assisted by software flow counterparts and it is believed that it
   is the wrong approach to push all the necessary context for the
   decision down into the kernel. This can be argued about and I don't
   feel strongly either way.
