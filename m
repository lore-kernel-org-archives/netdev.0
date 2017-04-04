From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net: netfilters: Remove unnecessary parenthesis
Date: Tue, 4 Apr 2017 13:48:16 -0400
Message-ID: <20170404174816.GC7257@verge.net.au>
References: <20170328132648.GA6644@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, Julian Anastasov <ja@ssi.bg>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        davem@davemloft.net, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170328132648.GA6644@arushi-HP-Pavilion-Notebook>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 06:56:48PM +0530, Arushi Singhal wrote:
> Rmoved parentheses on the right hand side of assignment, as they are
> not required. The following coccinelle script was used to fix this
> issue:
> 
> @@
> local idexpression id;
> expression e;
> @@
> 
> id =
> -(
> e
> -)
> 
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_proto_tcp.c   | 2 +-

grep seems to find some other instances of this problem for IPVS.
I would prefer if all of them were fixed.

$ grep -n "= *(.*);" net/netfilter/ipvs/*
After some manual filtering I see

net/netfilter/ipvs/ip_vs_ctl.c:113:     nomem = (availmem < ipvs->sysctl_amemthresh);
net/netfilter/ipvs/ip_vs_ctl.c:279:     ahash ^= ((size_t) ipvs >> 8);
net/netfilter/ipvs/ip_vs_proto_tcp.c:490:       int on = (flags & 1);          /* secure_tcp */
net/netfilter/ipvs/ip_vs_proto_tcp.c:498:       pd->tcp_state_table = (on ? tcp_states_dos : tcp_states);
net/netfilter/ipvs/ip_vs_sync.c:719:    s->v4.type = (cp->af == AF_INET6 ? STYPE_F_INET6 : 0);
net/netfilter/ipvs/ip_vs_sync.c:948:                    cp->timeout = (3*60*HZ)

As mentioned elsewhere: If you would like me to pick up patches for IPVS
then please post patches that only update IPVS files. I'm also happy for
Pablo to pick up patches that include both IPVS and non-IPVS Netfilter
updates of this nature.  Pablo can offer his own guidance here.

