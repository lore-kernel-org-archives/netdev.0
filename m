From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 07/10] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Mon, 10 Nov 2014 14:04:52 +0000
Message-ID: <20141110140452.GB19157@casper.infradead.org>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-8-git-send-email-jiri@resnulli.us>
 <5460B989.8030404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58520 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbaKJOEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 09:04:54 -0500
Content-Disposition: inline
In-Reply-To: <5460B989.8030404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 at 08:11am, Jamal Hadi Salim wrote:
> You are unconditionally calling
> netdev_sw_port_stp_update(p->dev, p->state);
> Again issue is policy. Could you make this work the same
> way the fdb_add e.g user intent of whether i want to turn
> a port in hardware and/or software to disabled/learning/etc
> is reflected?

Agreed. Can be added in a next series perhaps?

> btw: does _sw_ stand for switch? why not _hw_ ?
> Could we have one ndo for all flags instead of individual ones.
> 
> I know the current user space code uses u8 as a bitflag; but
> maybe we can introduce a new u32 flag bitmask that has all the
> flags set for backward compat? I can count about a total of 10.

I think we can just extend the size of IFLA_BRPORT_STATE, accept
both a u8 and u32, and return a u32 that that is compatible to
existing u8 readers.
