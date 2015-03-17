From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 nf-next 1/6] net: untangle ip_fragment and bridge
 netfilter
Date: Tue, 17 Mar 2015 00:42:24 -0400 (EDT)
Message-ID: <20150317.004224.595812379252826772.davem@davemloft.net>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
	<1426179925-18220-2-git-send-email-fw@strlen.de>
	<20150316225545.GA4454@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150316225545.GA4454@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 16 Mar 2015 23:55:45 +0100

> This patch changes the interface ip_fragment(). If this sounds
> reasonable to you, please ack it and I'll route it to you in the next
> nf-next batch.

I really think bridging netfilter needs to stop pretending.

Specifically it needs to stop pretending it can do full on IP
operations like fragmentation without the full necessary context.

That full necessary context being a physical destination device,
and a proper IP route.

It means that all of the MTU calculations miss everything done
by the ipv4 routing layer, all of the settings made by the user
via sysctl_ip_fwd_use_pmtu, etc.

So I think bridge netfilter needs to seriously look up a real
route and do things properly like the rest of the networking
stack does when it wants to fragment ipv4 packets.

And this just creates another hole for the openvswitch folks to
crawl through instead of fixing their architectural mistakes.
