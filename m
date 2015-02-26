From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 12:51:43 +0000
Message-ID: <20150226125143.GB23050@casper.infradead.org>
References: <20150226074214.GF2074@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, jpettit@nicira.com, joestringer@nicira.com,
	john.r.fastabend@intel.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, simon.horman@netronome.com,
	shrijeet@gmail.com, gospo@cumulusnetworks.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56968 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbbBZMvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 07:51:50 -0500
Content-Disposition: inline
In-Reply-To: <20150226074214.GF2074@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/15 at 08:42am, Jiri Pirko wrote:
> Hello everyone.
> 
> I would like to discuss big next step for switch offloading. Probably
> the most complicated one we have so far. That is to be able to offload flows.
> Leaving nftables aside for a moment, I see 2 big usecases:
> - TC filters and actions offload.
> - OVS key match and actions offload.
> 
> I think it might sense to ignore OVS for now. The reason is ongoing efford
> to replace OVS kernel datapath with TC subsystem. After that, OVS offload
> will not longer be needed and we'll get it for free with TC offload
> implementation. So we can focus on TC now.
>
> Here is my list of actions to achieve some results in near future:
> 1) finish cls_openflow classifier and iproute part of it

I still think that you should consider renaming this or merging
it with cls_flow. I don't see any relation to OpenFlow in what
you proposed in the last RFC.

> 2) extend switchdev API for TC cls and acts offloading (using John's flow api?)
> 3) use rocker to provide offload for cls_openflow and couple of selected actions
> 4) improve cls_openflow performance (hashtables etc)
> 5) improve TC subsystem performance in both slow and fast path
>     -RTNL mutex and qdisc lock removal/reduction, lockless stats update.
> 6) implement "named sockets" (working name) and implement TC support for that
>     -ingress qdisc attach, act_mirred target
> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets
> 8) implement TC act_mpls
> 9) suggest to switch OVS userspace from OVS genl to TC API

I think everybody agrees to unifying code paths and getting rid
of parallism assuming that it does not introduce a performance
regression for flow setup rate, throughput, and scale.

I would also include Linux bridge in this effort as it's also
based on programmable flows and would thus also benefit from
the implemented offload functionality.
