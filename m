From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Mon, 1 Feb 2016 11:01:30 -0500
Message-ID: <20160201160130.GA22816@oracle.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
 <1454286240.7627.160.camel@edumazet-glaptop2.roam.corp.google.com>
 <56AEA947.409@gmail.com>
 <56AF77C3.2010406@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32619 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbcBAQBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 11:01:41 -0500
Content-Disposition: inline
In-Reply-To: <56AF77C3.2010406@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/01/16 16:20), Nicolas Dichtel wrote:
> There is also the tile architecture, up to 76 cores on the board I've seen. It
> requires an alignment on 8!
> I wonder how this case may be properly handled. A simple ipip scenario fails.

Yes, I'm also observing the same thing. Simply setting up gretap like this
results in

# ip link add gretap2 type gretap local myaddr remote hisaddr
# ifconfig gretap2 up

Kernel unaligned access at TPC[969d88] iptunnel_xmit+0xa4/0x1c0
Kernel unaligned access at TPC[969db0] iptunnel_xmit+0xcc/0x1c0
Kernel unaligned access at TPC[969dc4] iptunnel_xmit+0xe0/0x1c0
Kernel unaligned access at TPC[969dc8] iptunnel_xmit+0xe4/0x1c0
Kernel unaligned access at TPC[9191fc] __ip_select_ident+0x80/0x13c

and afacit, the unaligned ip header is triggered by an inner ipv6 packet
that is usually coming from mld or dad.

(and fwiw, the basic iperf/ipv6 test is fine with Tom's patch, need
to try out some of the other permutations without rps etc)
