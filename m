From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH] NETFILTER module xt_hmark new target for HASH MARK
Date: Thu, 3 Feb 2011 18:37:32 +0100
Message-ID: <201102031837.32971.hans@schillstrom.com>
References: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com> <4D4ACCCB.8030902@netfilter.org> <4D4AD157.50707@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D4AD157.50707@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, February 03, 2011 17:01:27 Pablo Neira Ayuso wrote:
> On 03/02/11 16:42, Pablo Neira Ayuso wrote:
> > On 03/02/11 15:23, Hans Schillstrom wrote:
> >> On Thu, 2011-02-03 at 14:51 +0100, Pablo Neira Ayuso wrote:
> >>> On 03/02/11 14:34, Hans Schillstrom wrote:
> >>> this assumption is not valid in NAT handlings.
> >>
> >> That's true, because I want to avoid conntrack
> >>
> >>> If you want consistent hashing with NAT handlings you'll have to make
> >>> this stateful and use the conntrack source and reply directions of the
> >>> original tuples (thus making it stateful). That may be a problem because
> >>> some people may want to use this without enabling connection tracking.
> >>
> >> What about a compilation switch or a sysctl ?
> > 
> > or better some option for iptables.
> 
> Hm, this is actually not straight forward to implement, you'll have to
> use hook functions to avoid the module dependencies with conntrack and
> that's pretty annoying.
> 
> I don't come up with a good solution for this.

A configuration switch might be OK.

> 
> >>> Are you using this for (uplink) load balancing?
> >>
> >> Actually in both ways 
> >>  - in front of a bunch of ipvs
> 
> to make some preliminary load-sharing between the load balancers?

Yes that's right
and in the payloads send the return traffic in the same path.

> 
> >>  - and in the payloads for outgoing traffic.
> 
> and then to select the uplink, right?
> 

Yes.
It also has the same role for cluster originated traffic to spread the load over multiple interfaces,
and catch the return traffic.
