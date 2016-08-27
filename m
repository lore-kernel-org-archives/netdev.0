From: Eli Cooper <elicooper@gmx.com>
Subject: Re: [PATCH] ipv6: Don't unset flowi6_proto in ipxip6_tnl_xmit()
Date: Sat, 27 Aug 2016 09:09:11 +0800
Message-ID: <041aebd0-7ecc-f407-57d0-ad6a235f323e@gmx.com>
References: <20160826155229.8040-1-elicooper@gmx.com>
 <20160826224923.62827d04@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:54297 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752303AbcH0BJa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 21:09:30 -0400
In-Reply-To: <20160826224923.62827d04@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 2016/8/27 3:49, Shmulik Ladkani wrote:
> However new users of 'ip6_tnl_xmit' (e.g. __gre6_xmit callers) may still
> have their 'fl6->flowi6_proto' not armed.
>
> Maybe the right fix is assigning 'fl6->flowi6_proto = proto', either at
> start of 'ip6_tnl_xmit' or just prior the ip6_route_output() call.

The only other user of ip6_tnl_xmit() is ip6gre, and it has its
fl6->flowi6_proto set in ip6gre_tnl_link_config() as in commit
252f3f5a1189 ("ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit path.")

Assigning flowi6_proto at the start of ip6_tnl_xmit() was also my first
idea, but I was unsure which fix would be better.

Thanks,
Eli
