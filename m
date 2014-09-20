From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 12:51:40 +0100
Message-ID: <20140920115140.GA3777@casper.infradead.org>
References: <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
 <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com>
 <541CAA3C.5080105@intel.com>
 <541CAB9A.3040100@mojatatu.com>
 <20140920081702.GF1821@nanopsycho.orion>
 <541D54BA.6070709@mojatatu.com>
 <20140920110121.GB29419@casper.infradead.org>
 <541D65CE.7080108@mojatatu.com>
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
Received: from casper.infradead.org ([85.118.1.10]:45810 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbaITLvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 07:51:47 -0400
Content-Disposition: inline
In-Reply-To: <541D65CE.7080108@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/14 at 07:32am, Jamal Hadi Salim wrote:
> I am sorry to have tied the two together. Maybe not OVS but the approach
> described is heaven for vendor SDKs.

I fail to see the connection. You can use switch vendor SDK no matter
how we define the kernel APIs. They already exist and have been
designed in a way to be completely indepenedent from the kernel.

Are you referring to vendor specific decisions in user space in
general? I believe that the whole point of swdev is to provide *that*
level of abstraction so decisions can be made in a vendor neutral way.

> >The statement was that the requirement of deriving hardware flows from
> >software flows *in the kernel* is not flexible enough for the future
> >for reasons such as:
> >
> >1) The OVS software data path might be based on eBPF in the future and
> >    it is unclear how we could derive hardware flows from that
> >    transparently.
> >
> 
> Who says you cant put BPF in hardware?

I don't think anybody is saying that. P4 is likely a reality soon. But
we definitely want hardware offload in a BPF world even if the hardware
can't do BPF yet.

> And why is OVS defining how BPF should evolve or how it should be used?

Not sure I understand. OVS would be a user of eBPF just like tracing,
xt_BPF, socket filter, ...

> >2) Depending on hardware capabilities. Hardware flows might need to be
> >    assisted by software flow counterparts and it is believed that it
> >    is the wrong approach to push all the necessary context for the
> >    decision down into the kernel. This can be argued about and I don't
> >    feel strongly either way.
> >
> 
> Pointing to the current FDB offload: You can select to bypass
> and not use s/ware.

As I said, this can be argued about. It would require to push a lot of
context into the kernel though. The FDB offload is relatively trivial
in comparison to the complexity OVS user space can handle. I can't think
of any reasons why to complicate the kernel further with OVS specific
knowledge as long as we can guarantee the vendor abstraction.
