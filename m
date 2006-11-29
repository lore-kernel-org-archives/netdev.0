From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [PATCH] [IPVS] transparent proxying
Date: Wed, 29 Nov 2006 23:26:51 +0800
Message-ID: <456DA6BB.6080800@linux-vs.org>
References: <20061129062126.GP25535@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	Jinhua Luo <home_king@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [202.109.113.90] ([202.109.113.90]:57737 "EHLO
	dragon.linux-vs.org") by vger.kernel.org with ESMTP id S967419AbWK2P0y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 10:26:54 -0500
To: Horms <horms@verge.net.au>
In-Reply-To: <20061129062126.GP25535@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Horms,

I see that this patch probably makes IPVS code a bit complicated and 
packet traversing less efficiently.

If I remember correctly, policy-based routing can work with IPVS in 
kernel 2.2 and 2.4 for transparent cache cluster for a long time. It 
should work in kernel 2.6 too.

For example, we can use iptables/ipchains to mark all web traffic with 
fwmark 1, then use policy-based routing to route all web traffic through 
NF_IP_LOCAL_IN, so that ip_vs_in can capture the packets and load 
balance packets to cache servers.
ip rule add prio 100 fwmark 1 table 100
ip route add local 0/0 dev lo table 100

ipvsadm -A -f 1 -s wlc
ipvsadm -a -f 1 -w 100 -r cache1
ipvsadm -a -f 1 -w 100 -r cache2
ipvsadm -a -f 1 -w 100 -r cache2

...

Cheers,

Wensong

Horms wrote:
> This seems to be a pretty clean solution to a real problem.
>
> Ultimately I would like to see IPVS move into the forward chain.
> This seems to be a nice way to explore that, without breaking
> any existing setups.
>
>   

