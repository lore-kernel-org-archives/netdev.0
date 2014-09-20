From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 11:53:54 +0100
Message-ID: <20140920105354.GA29419@casper.infradead.org>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
 <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
 <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com>
 <541CAA3C.5080105@intel.com>
 <20140920081426.GE1821@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com, edumazet@google.com,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45625 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbaITKyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 06:54:03 -0400
Content-Disposition: inline
In-Reply-To: <20140920081426.GE1821@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/14 at 10:14am, Jiri Pirko wrote:
> Sat, Sep 20, 2014 at 12:12:12AM CEST, john.r.fastabend@intel.com wrote:
> >I was considering a slightly different approach where the
> >device would report via netlink the fields/actions it
> >supported rather than creating pre-defined enums for every
> >possible key.
> >
> >I already need to have an API to report fields/matches
> >that are being supported why not have the device report
> >the headers as header fields (len, offset) and the
> >associated parse graph the hardware uses? Vendors should
> >have this already to describe/design their real hardware.
> 
> Hmm, let me think about this a bit more. I will try to figure out how to
> handle that. Sound logic though. Will try to incorporate the idea in the
> patchset.

I think this is the right track.

I agree with Jamal that there is no need for a new permanent and
separate Netlink interface for this. I think this would best be described
as a structure of nested Netlink attributes in the form John proposes
which is then embedded into existing Netlink interfaces such as rtnetlink
and OVS genl.

OVS can register new genl ops to check capabilities and insert
hardware flows which allows implementation of the offload decision in
user space and allows for arbitary combination of hardware and software
flows. It also allows to run a eBPF software data path in combination
with a hardware flow setup.

rtnetlink can embed the nested attribute structure into existing APIs
to allow feature capability detection from user space, statistic
reporting and optional direct hardware offload if a transaprent
offload is not feasible. Would that work for you John?

I think we should focus on getting the layering right and make it
generic enough so we allow evolving naturally.
