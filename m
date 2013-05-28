From: Cong Wang <amwang@redhat.com>
Subject: Re: Some netfilter compile errors when CONFIG_IPV6=m
Date: Tue, 28 May 2013 10:47:55 +0800
Message-ID: <1369709275.8181.43.camel@cr0>
References: <1368499552.2507.5.camel@cr0> <20130527123339.GA16150@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21302 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758611Ab3E1CsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 22:48:07 -0400
In-Reply-To: <20130527123339.GA16150@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-27 at 14:33 +0200, Pablo Neira Ayuso wrote:
> On Tue, May 14, 2013 at 10:45:52AM +0800, Cong Wang wrote:
> > Hi, all
> > 
> > I got the following compile errors when I compile IPv6 as a module and
> > most of the rest are built into core kernel. David Miller insists we
> > should fix this kind of error and not by adding Kconfig tricks.
> > 
> > net/built-in.o: In function `nf_tproxy_get_sock_v6':
> > /home/wangcong/linux/include/net/netfilter/nf_tproxy_core.h:177:
> > undefined reference to `udp6_lib_lookup'
> > /home/wangcong/linux/include/net/netfilter/nf_tproxy_core.h:177:
> > undefined reference to `udp6_lib_lookup'
> > net/built-in.o: In function `tproxy_tg_init':
> > /home/wangcong/linux/net/netfilter/xt_TPROXY.c:415: undefined reference
> > to `nf_defrag_ipv6_enable'
> > net/built-in.o: In function `socket_mt_init':
> > /home/wangcong/linux/net/netfilter/xt_socket.c:366: undefined reference
> > to `nf_defrag_ipv6_enable'
> 
> Looking at your incomplete .config, I don't see how you set xt_TPROXY
> and xt_socket but I bet they are =y.
> 
> For the udp6_lib_lookup dependency, you can use the ipv6 hooks added
> here:
> 
> commit 2a7851bffb008ff4882eee673da74718997b4265
> Author: Florian Westphal <fw@strlen.de>
> Date:   Fri May 17 03:56:10 2013 +0000
> 
>     netfilter: add nf_ipv6_ops hook to fix xt_addrtype with IPv6
> 
> Already in the nf tree, to resolve it. It would be fairly easy to make
> a patch for it.

Next time please Cc me, the reporter, when you submit a fix, otherwise I
don't know if it is fixed, since I don't subscribe nf mailing list.

> 
> For the nf_defrag_ipv6_enable, as I already mentioned, that's an
> artificial function to enforce the dependency between those two
> modules. We can add runtime checks in socket and TPROXY to skip
> further processing is nf_defrag_ipv6 is not loaded. But that's a
> problem because users will assume that their socket/TPROXY rule got
> loaded but it will not actually work since defrag is not loaded.  I
> think that really needs some Kconfig tricks for that specific case.
> 

Yeah, please send a fix? I can test it (together with my vxlan patches)
if you need. I have no cycles to work on it even if it is simple. :)

Thanks!
