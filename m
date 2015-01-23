From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 15:49:49 +0000
Message-ID: <20150123154949.GM25797@casper.infradead.org>
References: <20150122153727.GC25797@casper.infradead.org>
 <54C11ACC.5010005@mojatatu.com>
 <20150123101019.GF25797@casper.infradead.org>
 <20150123102421.GB2065@nanopsycho.orion>
 <20150123110821.GH25797@casper.infradead.org>
 <20150123113934.GD2065@nanopsycho.orion>
 <20150123122838.GI25797@casper.infradead.org>
 <20150123134315.GF2065@nanopsycho.orion>
 <20150123140724.GJ25797@casper.infradead.org>
 <20150123152556.GG2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47540 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbAWPtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:49:51 -0500
Content-Disposition: inline
In-Reply-To: <20150123152556.GG2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 at 04:25pm, Jiri Pirko wrote:
> Fri, Jan 23, 2015 at 03:07:24PM CET, tgraf@suug.ch wrote:
> >How does John's API fit into this? How would you expose capabilities
> >through xflows? How would it differ from what John proposes?
> 
> This certainly need more thinking. The capabilities could be exposed
> either by separate a genl api (like in this version) or directly via TC
> netlink iface (RTM_GETTFILTERCAP, RTM_GETACTIONCAP). The insides of the
> message can stay the same. I like the second way better.

OK. Any particular reason why you like the tc integration better?

> flow manipulation would happen as standard TC filters/actions manipulation.
> Here, the Netlink messages could be also very similar to what John has now.

I have one concern here: This would mean we put flow modifications
under the rtnl lock which will have severe impact on the rate of
flow modifications we can support. We need flow table modifications
to continue being super fast.

Parallel genetlink operations were introduced just for this.

> Right. We have to either introduce some limitations for xflows to
> disallow this or let the user to take care of this. But it's similar
> problem as if you use tc with John's API or ovs with John's API.

Agreed. It's a general problem with having multiple indepdent tools.
