From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [Bridge] [PATCH net-next] net: bridge: add support for IGMP/MLD
 stats and export them via netlink
Date: Tue, 28 Jun 2016 13:03:21 +0200
Message-ID: <20160628110321.GA3221@otheros>
References: <1467051048-32604-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.aperture-lab.de ([138.201.29.205]:58985 "EHLO
	mail.aperture-lab.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbcF1LDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 07:03:25 -0400
Content-Disposition: inline
In-Reply-To: <1467051048-32604-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 08:10:48PM +0200, Nikolay Aleksandrov via Bridge wrote:
> These are invaluable when monitoring or debugging complex multicast setups
> with bridges.

Indeed! Great patch :). Especially if people are unable to provide
pcap files for debugging (due to whatever reason). Hopefully that
will help with bugzilla ticket #99081, too...

I know it might not quite fit into your current patch, which simply
stores the ICMPv6 and IGMP type in the bridge private skb->cb, but
do you think you could count and export the following two more
things, too:

* MLDv1 vs. MLDv2 querier (and IGMP accordingly)
* Number of (potential) MLD/IGMP parse errors
  (e.g. beginning of br_multicast_ipv{4,6}_rcv():
   http://lxr.free-electrons.com/source/net/bridge/br_multicast.c?v=4.5#L1588 and
   http://lxr.free-electrons.com/source/net/bridge/br_multicast.c?v=4.5#L1634)

The former would help to know how the network is expected to
behave (for instance whether you should see MLDv2 reports at all or
whether / how much report suppression to expect).

The latter would help to spot either potential IGMP/MLD parsing bugs in
the bridge or malformed IGMP/MLD messages send by someone else.


Ideally, there would be per port counters again for the overall
IPv4/IPv6 multicast traffic. That would help for multicast streams
for instance, to easily see whether multicast counters increase
rapidly on the ports you would expect them to. And whether snooping
is working in general for such streames, without needing to check
each port individually via tcpdump, for instance.


Just some thoughts, would love to hear what you think about them.

Regards, Linus
