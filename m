From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Fri, 10 Apr 2015 11:03:17 +0100
Message-ID: <20150410100317.GD23070@casper.infradead.org>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
 <20150409.173423.2258417584616634411.davem@davemloft.net>
 <20150410091203.GA2021@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jhs@mojatatu.com, jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32818 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161AbbDJKDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 06:03:20 -0400
Content-Disposition: inline
In-Reply-To: <20150410091203.GA2021@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/15 at 11:12am, Jiri Pirko wrote:
> Thu, Apr 09, 2015 at 11:34:23PM CEST, davem@davemloft.net wrote:
> >I'm not so sure what my opinion is about whether we should
> >even have an openflow classifier or not (I find major aspects
> >of OpenFLOW extremely distasteful, it's basically pushing the
> >SDK agenda of several major chip vendors).
> 
> Yep, I don't like OpenFlow as well. But anyway, we already have
> OpenFlow-based classifier in kernel - in OVS code.

Can we stop referring to OpenFlow? There is really no relation ;-)
In fact, there are several open source projects which utilize the
OVS kernel datapath *without* caring about OpenFlow at all. A good
example of this is Midonet.

> The thing is, why don't have it in tc? It does not cost anything. And
> having it, people used to use ovs kernel DP will be able to migrate
> easily to tc.

That part I agree with. We should have a single common flow dissector
which is used for all purposes. After all, it's just parsing and
wildcard matching through hash tables. If that flow dissector is not
rich enough for someone, eBPF offers a more programmable approach and
we already see that work progressing nicely. We should also
consolidate as much of the actions as possible.

As I stated in a private email to a couple of days ago. I've started
working on ripping out most of the OVS vport logic and make all OVS
bridge ports be regular net_devices (most of them already were). This
will get rid of most of the OVS specific tunnel handling logic and
should allow to implement flow based tunnels with iproute2 as well.
The OVS datapath structure will just become net_device private data
and all ports will be regular slaves.

Adding slaves to an OVS bridge will be possible through iproute2
and we can even expose OVS bridges as regular Linux bridges ithrough
AF_BRIDGE *if* we want. Although I'm not sure how feasiable that is
given that most Linux bridge knobs including all the STP config
does not apply to OVS bridges.

I think everybody agrees that we should melt as much as possible and
stop reimplementing everything from scratch in isolated silos for
every bridge flavour that pops up.
