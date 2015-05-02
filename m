From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH net-next v3 6/9] ipv6: Set FLOWI_FLAG_KNOWN_NH at
 flowi6_flags
Date: Sat, 2 May 2015 15:21:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1505021453360.1526@ja.home.ssi.bg>
References: <1430526418-3132761-1-git-send-email-kafai@fb.com> <1430526418-3132761-7-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49868 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751276AbbEBMVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 08:21:22 -0400
In-Reply-To: <1430526418-3132761-7-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 1 May 2015, Martin KaFai Lau wrote:

> The neighbor look-up used to depend on the rt6i_gateway (if
> there is a gateway) or the rt6i_dst (if it is a RTF_CACHE clone)
> as the nexthop address.  Note that rt6i_dst is set to fl6->daddr
> for the RTF_CACHE clone where fl6->daddr is the one used to do
> the route look-up.
> 
> Now, we only create RTF_CACHE clone after encountering exception.
> When doing the neighbor look-up with a route that is neither a gateway
> nor a RTF_CACHE clone, the daddr in skb will be used as the nexthop.
> 
> In some cases, the daddr in skb is not the one used to do
> the route look-up.  One example is in ip_vs_dr_xmit_v6() where the
> real nexthop server address is different from the one in the skb.
> 
> This patch is going to follow the IPv4 approach and ask the
> ip6_pol_route() callers to set the FLOWI_FLAG_KNOWN_NH properly.
> 
> In the next patch, ip6_pol_route() will honor the FLOWI_FLAG_KNOWN_NH
> and create a RTF_CACHE clone.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Julian Anastasov <ja@ssi.bg>

	I applied all 9 patches to net-next and tested
IPVS-DR. We are properly resolving the nexthop saved in
route. Then I commented the FLOWI_FLAG_KNOWN_NH flag
in IPVS and checked that daddr from packet was used. As
expected, DR metod fails here. So, the new flag appears
to work correctly.

	I didn't analyzed the IPv6 changes but the
IPVS changes look good to me:

Acked-by: Julian Anastasov <ja@ssi.bg>
Tested-by: Julian Anastasov <ja@ssi.bg>

Thanks!
