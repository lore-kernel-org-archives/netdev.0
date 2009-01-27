From: Patrick McHardy <kaber@trash.net>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 10:15:14 +0100
Message-ID: <497ED0A2.6050707@trash.net>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com> <497E44F6.2010703@hp.com> <497ECF84.1030308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497ECF84.1030308@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> [PATCH] netfilter: Get rid of central rwlock in tcp conntracking
> 
> TCP connection tracking suffers of huge contention on a global rwlock,
> used to protect tcp conntracking state.
> As each tcp conntrack state have no relations between each others, we
> can switch to fine grained lock, using a spinlock per "struct ip_ct_tcp"
> 
> tcp_print_conntrack() dont need to lock anything to read ct->proto.tcp.state,
> so speedup /proc/net/ip_conntrack as well.

Thats an interesting test-case, but one lock per conntrack just for
TCP tracking seems like overkill. We're trying to keep the conntrack
stuctures as small as possible, so I'd prefer an array of spinlocks
or something like that.

