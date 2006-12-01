From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [PATCH] [IPVS] transparent proxying
Date: Fri, 01 Dec 2006 23:41:37 +0800
Message-ID: <45704D31.4070206@linux-vs.org>
References: <456E389E.7090809@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Horms <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>, Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [202.109.113.90] ([202.109.113.90]:17357 "EHLO
	dragon.linux-vs.org") by vger.kernel.org with ESMTP id S967383AbWLAPlm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 10:41:42 -0500
To: home_king <home_king@163.com>
In-Reply-To: <456E389E.7090809@163.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Jinhua,

home_king wrote:
> hi, Wensong. Thanks for your appraise.
>
> > I see that this patch probably makes IPVS code a bit complicated and
> > packet traversing less efficiently.
>
> In my opinion, worry about the side-effect to the packet throughput is 
> not
> necessary. First, normal packets with mark rarely appear in the 
> NF_IP_FORWARD
> chain, while people mark packets aiming at the network administration job
> usually on the NF_IP_LOCAL_IN or NF_IP_OUTPUT chain. Second, the new 
> hook fn
> is called after ipvs SNAT hook fn, and pass the packets handled by the 
> latter
> hook fn by simply checking the ipvs_property flag, so it would not 
> disturb the
> SNAT job. Third, the new hook fn is just a thin wrapper of ip_vs_in(), 
> so now
> that all packets which go through NF_IP_LOCAL_IN will be entirely 
> checked up
> by ip_vs_in(), no matter they are virtual-server relative or not, why 
> we mind
> that a comparatively small quantity of packets which go through 
> NF_IP_FORWARD
> will be checked too?
>
I see that every firewall-marked packet will be checked by ip_vs_in(), 
no matter whether
the packet is related to IPVS or not. It's a bit less efficient.
> > If I remember correctly, policy-based routing can work with IPVS in
> > kernel 2.2 and 2.4 for transparent cache cluster for a long time. It
> > should work in kernel 2.6 too.
>
> Indeed, policy route can help too, but the patch provides a native 
> manner to
> deploy transparent proxy, and meanwhile, this manner will not break the
> backbone networking context, such as policy routing setting, iptables 
> rules,
> etc.
I am afraid that the method used in the patch is not native, it breaks 
on IP fragments.
IPVS is a kind of layer-4 switching, it routes packet by checking 
layer-4 information
such as address and port number. ip_vs_in() is hooked at NF_IP_LOCAL_IN, so
that all the packets received by ip_vs_in() are already defragmented. On 
NF_IP_FORWARD
hook, there may be some IP fragements, ip_vs_in() cannot handle those IP 
fragments.

I think that it's probably better to let each part do its own things in 
the design.

Cheers,

Wensong

