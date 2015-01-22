From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 15:13:16 +0000
Message-ID: <20150122151316.GB25797@casper.infradead.org>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42223 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbbAVPNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:13:19 -0500
Content-Disposition: inline
In-Reply-To: <54C11094.2000807@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 at 10:00am, Jamal Hadi Salim wrote:
> On 01/22/15 09:00, Pablo Neira Ayuso wrote:
> 
> >
> >+/* rocker specific action definitions */
> >+struct net_flow_action_arg rocker_set_group_id_args[] = {
> >+       {
> >+               .name = "group_id",
> >+               .type = NFL_ACTION_ARG_TYPE_U32,
> >+               .value_u32 = 0,
> >+       },
> >
> >that is retrieved via ndo_flow_get_actions and fully exposed to
> >userspace.
> >
> 
> My main concern is along similar lines (I did express it earlier and
> I think Jiri chimed in as well).
> The API exposes direct access to hardware. I am sure this was a result
> of trying to replace the ethtool interface (which was primitive).
> By providing vendors direct access to the hardware - they do not need
> to use any traditional Linux tooling/APIs.

I don't follow this. John's proposal allows to decide on a case by
case basis what we want to export. Just like with ethtool or
RTNETLINK. There is no direct access to hardware. A user can only
configure what is being exposed by the kernel.

Pablo raises an interesting point though. How do we handle unique
features like Rocker groups.

Maybe Jiri and Scott can chime in and describe if we can map this to
something more generic and avoid exporting anything Rocker specific.

What would a rocker group map to in the tc world?

> I see this as a gaping hole
> for vendor SDKs with their own definitions of their own hardware that
> doesnt work with anyone else. i.e it seems to standardize proprietary
> interfaces. Maybe thats what Pablo is alluding to.

I will be the first to root for rejection if such patches appear.
