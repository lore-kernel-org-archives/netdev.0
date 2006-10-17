From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 13/13] [RFC] [IPV6] Fix source prefix routing problems when source address undefined.
Date: Tue, 17 Oct 2006 14:34:15 +0200
Message-ID: <20061017123415.GO12964@postel.suug.ch>
References: <20061017101402.GM12964@postel.suug.ch> <20061017.200005.70903049.yoshfuji@linux-ipv6.org> <20061017113511.GN12964@postel.suug.ch> <20061017.211730.51920084.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vnuorval@tcs.hut.fi, davem@davemloft.net, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:23783 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750738AbWJQMdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 08:33:55 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20061017.211730.51920084.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2006-10-17 21:17
> In article <20061017113511.GN12964@postel.suug.ch> (at Tue, 17 Oct 2006 13:35:11 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> :
> > different logic. In order to solve this, rules must be restricted to
> > one of these paths, i.e. a rule intending to make certain prefixes
> > unreachable may not apply to the source selection logic. This can be
> > achieved using the 'reason' field I proposed in my netconf slides, it
> > would allow turning the first rule example into
> > 
> > 	rule add from 2001::1/128 for INPUT unreachable
> > 
> > which would no longer apply when looking up the source address or
> > deciding the outgoing route.
> 
> And/or, to take into account input interface, we could do
> 	rule add from 2001::1/128 in eth0 unreachable
> maybe.

Right, that works as well but duplicating the rule for every
interface is not very practical.

Anyways, the point is that the proposed change to modify the
source prefix matching logic is not acceptable and other way
has to be found.
