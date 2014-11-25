From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 08/17] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Tue, 25 Nov 2014 22:18:45 +0000
Message-ID: <20141125221845.GG3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-9-git-send-email-jiri@resnulli.us>
 <20141125155832.GG27416@gospo.rtplab.test>
 <20141125165308.GL1971@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@k
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56789 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbaKYWSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:18:47 -0500
Content-Disposition: inline
In-Reply-To: <20141125165308.GL1971@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 05:53pm, Jiri Pirko wrote:
> Tue, Nov 25, 2014 at 04:58:32PM CET, gospo@cumulusnetworks.com wrote:
> >I do not expect that this first set would provide full feedback to
> >br_make_forwarding, br_make_blocking, etc, to allow spanning tree to
> >properly deal with the failure (that change is fine to add later), but a
> >short one-liner indicating that the call to the hardware  failed would e
> >good.  What about something simple like this:
> >
> >void br_set_state(struct net_bridge_port *p, unsigned int state)
> >{
> >	int ret;
> >	p->state = state;
> >	ret = netdev_switch_port_stp_update(p->dev, state);
> >	if (ret && ret != -EOPNOTSUPP)
> >		br_warn(br, "error setting offload STP state for interface %s\n",
> >			p->dev->name);
> >}
> 
> That makes sense. Will add this.

Feel free to add:
Acked-by: Thomas Graf <tgraf@suug.ch>
