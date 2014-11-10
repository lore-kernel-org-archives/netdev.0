From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 06/10] bridge: introduce fdb offloading via
 switchdev
Date: Mon, 10 Nov 2014 13:51:00 +0000
Message-ID: <20141110135100.GA19157@casper.infradead.org>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-7-git-send-email-jiri@resnulli.us>
 <54603564.3070606@mojatatu.com>
 <20141110081552.GD1850@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
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
	bcrl@
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58403 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbaKJNvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 08:51:08 -0500
Content-Disposition: inline
In-Reply-To: <20141110081552.GD1850@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 at 09:15am, Jiri Pirko wrote:
> There are few problems in re-using this. It is netlink based so for calling
> it from bridge code, we would have to construct netlink message. But
> that could be probably changed.
> As you can see from the list of parameters, this is no longer about fdb (addr,
> vlanid) but this has been extended to something else. See vxlan code for
> what this is used for. I believe that fdb_add/del should be renamed to
> something else, perhaps l2neigh_add/del or something like that.
> The other problem is that fdb_add/del is currently used by various
> drivers for different purpose (adding macs to unicast list).

Can you elaborate a bit on the intended semantic differences between
the existing ndo_fdb_add() and ndo_sw_port_fdb_add()? I'm not sure we
need the sw_ prefix for this specific ndo.

I completely agree that relying on Netlink is wrong because we'll have
in-kernel users of the API but I believe that existing ndo_fdb_add()
implementations in i40e, ixgbe, qlcnic and macvlan could use the new
API you propose.

How about we rename the existing ndo_fdb_add() to ndo_neigh_add() as
you propose and convert vxlan over to it and have all others which don't
even depend on the Netlink attributes being passed in (i40e, ixgbe,
qlcnic, macvlan) use ndo_fdb_add() which would have the behaviour of your
proposed ndo_sw_port_fdb_add()?
