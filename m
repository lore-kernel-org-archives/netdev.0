From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 23:16:51 +0000
Message-ID: <20150123231651.GA20339@casper.infradead.org>
References: <20150123174609.GA23242@casper.infradead.org>
 <54C2A805.7030401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49832 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbbAWXQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 18:16:55 -0500
Content-Disposition: inline
In-Reply-To: <54C2A805.7030401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Skipping the tc model part for now. Need some time to digest
 all of that]

On 01/23/15 at 11:59am, John Fastabend wrote:
> On 01/23/2015 09:46 AM, Thomas Graf wrote:
> >.... if we can get rid of the rtnl lock in the flow mod path ;-)
> 
> Well isn't it the qdisc lock here? And its not needed anymore for
> filters/actions only qdisc's use it because they are not lock-safe
> yet. Its been on my backlog to start replacing the skb lists with
> lock-free rings but I haven't got anywhere on this yet.
> 
> Although a hardware doesn't really need a queuing discipline its
> done in hardware so you could drop the qdisc lock in this case.

I'm not even in the data path yet with that comment. I'm worried
with the locking in the control path as talking rtnetlink implies
taking rtnl for each flow modification.

Agreed that we wouldn't depend on the qdisc lock for offloaded flows.
