From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 11:08:21 +0000
Message-ID: <20150123110821.GH25797@casper.infradead.org>
References: <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
 <54C11ACC.5010005@mojatatu.com>
 <20150123101019.GF25797@casper.infradead.org>
 <20150123102421.GB2065@nanopsycho.orion>
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
Received: from casper.infradead.org ([85.118.1.10]:46408 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294AbbAWLIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 06:08:22 -0500
Content-Disposition: inline
In-Reply-To: <20150123102421.GB2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 at 11:24am, Jiri Pirko wrote:
> I think that comparing this to team or routing userspace is not
> correct. The reason is that team and routing has single api to kernel.
> However in this case userspace has to use multiple APIs.

The point I was trying to make is that there are legitimate reasons
to keep complexity out of the kernel and team is a good example for
that.

As for multiple APIs. Team does in fact export its own Generic Netlink
interface while it also hooks into rtnetlink to support ip link. Not
sure whether that qualifies for multiple APIs or not but I think it's
an excellent architecture decision. Same as for nl80211 tools.

> For example OVS. It would have to use existing OVS gennetlink iface + this
> new flow netlink iface for flow offloads. For all others, this is the same.
> Multiple apis for the same thing (does not matter if it is implemented
> in hw or sw) does not seem right to me.

Fair enough. I have no objections to merging the flow API into RTNETLINK
although I don't really see a need to put more under the rtnl umbrella
unless absolutely required.

I think John also mentioned that he proposes to have this as a separate
Generic Netlink interface for now but this could really live wherever it
seems appropriate.
