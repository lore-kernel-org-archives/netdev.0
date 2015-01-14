From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v1 00/11] A flow API
Date: Wed, 14 Jan 2015 19:02:38 +0000
Message-ID: <20150114190238.GB2105@casper.infradead.org>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
 <54ABD3D1.6020608@mojatatu.com>
 <54B01DA2.9090104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, sfeldma@gmail.com,
	jiri@resnulli.us, simon.horman@netronome.com,
	netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60893 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbbANTCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:02:42 -0500
Content-Disposition: inline
In-Reply-To: <54B01DA2.9090104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/15 at 10:27am, John Fastabend wrote:
> Yes we are providing an interface for userspace to interrogate the
> hardware and program it. My take on this is even if you embed this
> into another netlink family OVS, NFT, TCA you end up with the same
> operations w.r.t. table support (a) query hardware for
> resources/constraints/etc and (b) an API to add/del rules in those
> tables. It seems the intersection of these features with existing
> netlink families is fairly small so I opted to create a new family.
> The underlying hardware offload mechanisms in flow_table.c here could
> be used by in-kernel consumers as well as user space. For some
> consumers 'tc' perhaps this makes good sense for others 'OVS'
> it does not IMO.

+1

> [...]
>
> But in many cases my goal is to unify them in userspace
> where it is easier to make policy decisions. For OVS, NFT it
> seems to me that user space libraries can handle the unification
> of hardware/software dataplanes. Further I think it is the correct
> place to unify the dataplanes. I don't want to encode complex
> policies into the kernel. Even if you embed the netlink UAPI into
> another netlink family the semantics look the same.

I think we want the kernel to remain in control but it does not
necessarily have to hold the offload decision logic for all users.
I think this is compareable to routing daemons. We do not want to
talk BPF or OSPF in the kernel and we don't need to know about all
of the selection logic behind it but we want to be in charge of
keeping track of the actual datapath routes.

Also, I think this is still an option to emebed the proposed
attribtues in existing Netlink families even if we shoot for a new
family for now. So far the attributes seem to be defined in a way
that would allow them to be embedded into other existing Netlink
families.

> Maybe I need to be enlightened but I thought for a bit about some grand
> unification of ovs, bridge, tc, netlink, et. al. but that seems like
> an entirely different scope of project. (side note: filters/actions
> are no longer locked by qdisc and could stand on their own) My thoughts
> on this are not yet organized.

I think everybody had this in the back of their mind at some point.
Be it based on BPF, NFT or TC. I don't think it's undoable but it
takes a lot of effort as each is based on a slightly different set
of assumptions with corresponding focus derived from that.
