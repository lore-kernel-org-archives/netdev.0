From: Patrick McHardy <kaber@trash.net>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 18:33:51 +0100
Message-ID: <497F457F.2050802@trash.net>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com> <497E44F6.2010703@hp.com> <497ECF84.1030308@cosmosbay.com> <497ED0A2.6050707@trash.net> <497F350A.9020509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497F350A.9020509@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> [PATCH] netfilter: Get rid of central rwlock in tcp conntracking
>
> TCP connection tracking suffers of huge contention on a global rwlock,
> used to protect tcp conntracking state.
>
> As each tcp conntrack state have no relations between each others, we
> can switch to fine grained lock. Using an array of spinlocks avoids
> enlarging size of connection tracking structures, yet giving reasonable
> fanout.
>
> tcp_print_conntrack() doesnt need to lock anything to read
> ct->proto.tcp.state, so speedup /proc/net/ip_conntrack as well.
>
> nf_conntrack_hash_rnd_initted & nf_conntrack_hash_rnd declared read_mostly
>   

This looks good to me. Rick, would you like to give it a try?

I'll convert the remaining conntrack protocols when applying it.
