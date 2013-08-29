From: Patrick McHardy <kaber@trash.net>
Subject: Re: [nf-next PATCH] netfilter: more strict TCP flag matching in
 SYNPROXY
Date: Thu, 29 Aug 2013 12:33:34 +0200
Message-ID: <20130829103334.GC14229@macbook.localnet>
References: <20130828131438.24364.25004.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, as@one.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52462 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895Ab3H2Kdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 06:33:37 -0400
Content-Disposition: inline
In-Reply-To: <20130828131438.24364.25004.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 03:14:38PM +0200, Jesper Dangaard Brouer wrote:
> Its seems Patrick missed to incoorporate some of my requested changes
> during review v2 of SYNPROXY netfilter module.
> 
> Which were, to avoid SYN+ACK packets to enter the path, meant for the
> ACK packet from the client (from the 3WHS).
> 
> Further there were a bug in ip6t_SYNPROXY.c, for matching SYN packets
> that didn't exclude the ACK flag.
> 
> Go a step further with SYN packet/flag matching by excluding flags
> ACK+FIN+RST, in both IPv4 and IPv6 modules.
> 
> 
> The intented usage of SYNPROXY is as follows:
> (gracefully describing usage in commit)
> 
>  iptables -t raw -A PREROUTING -i eth0 -p tcp --dport 80 --syn -j NOTRACK
>  iptables -A INPUT -i eth0 -p tcp --dport 80 -m state UNTRACKED,INVALID \
>          -j SYNPROXY --sack-perm --timestamp --mss 1480 --wscale 7 --ecn
> 
>  echo 0 > /proc/sys/net/netfilter/nf_conntrack_tcp_loose
> 
> This does filter SYN flags early, for packets in the UNTRACKED state,
> but packets in the INVALID state with other TCP flags could still
> reach the module, thus this stricter flag matching is still needed.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Patrick McHardy <kaber@trash.net>
