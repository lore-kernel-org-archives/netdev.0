From: home_king <home_king@163.com>
Subject: Re: [PATCH] [IPVS] transparent proxying
Date: Thu, 30 Nov 2006 09:49:18 +0800
Message-ID: <456E389E.7090809@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Horms" <horms@verge.net.au>, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>,
	"Julian Anastasov" <ja@ssi.bg>, "Joseph Mack NA3T" <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:51344 "HELO m12-14.163.com")
	by vger.kernel.org with SMTP id S967814AbWK3BvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 20:51:12 -0500
To: "Wensong Zhang" <wensong@linux-vs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi, Wensong. Thanks for your appraise.

 > I see that this patch probably makes IPVS code a bit complicated and
 > packet traversing less efficiently.

In my opinion, worry about the side-effect to the packet throughput is not
necessary. First, normal packets with mark rarely appear in the 
NF_IP_FORWARD
chain, while people mark packets aiming at the network administration job
usually on the NF_IP_LOCAL_IN or NF_IP_OUTPUT chain. Second, the new hook fn
is called after ipvs SNAT hook fn, and pass the packets handled by the 
latter
hook fn by simply checking the ipvs_property flag, so it would not 
disturb the
SNAT job. Third, the new hook fn is just a thin wrapper of ip_vs_in(), 
so now
that all packets which go through NF_IP_LOCAL_IN will be entirely checked up
by ip_vs_in(), no matter they are virtual-server relative or not, why we 
mind
that a comparatively small quantity of packets which go through 
NF_IP_FORWARD
will be checked too?

 > If I remember correctly, policy-based routing can work with IPVS in
 > kernel 2.2 and 2.4 for transparent cache cluster for a long time. It
 > should work in kernel 2.6 too.

Indeed, policy route can help too, but the patch provides a native manner to
deploy transparent proxy, and meanwhile, this manner will not break the
backbone networking context, such as policy routing setting, iptables 
rules,
etc.

