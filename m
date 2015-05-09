From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fixed source specific default route handling.
Date: Sat, 09 May 2015 15:59:33 -0400 (EDT)
Message-ID: <20150509.155933.1142748159005050614.davem@davemloft.net>
References: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: markus.stenberg@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Stenberg <markus.stenberg@iki.fi>
Date: Tue, 5 May 2015 13:36:59 +0300

> If there are only IPv6 source specific default routes present, the
> host gets -ENETUNREACH on e.g. connect() because ip6_dst_lookup_tail
> calls ip6_route_output first, and given source address any, it fails,
> and ip6_route_get_saddr is never called.
> 
> The change is to use the ip6_route_get_saddr, even if the initial
> ip6_route_output fails, and then doing ip6_route_output _again_ after
> we have appropriate source address available.
> 
> Note that this is '99% fix' to the problem; a correct fix would be to
> do route lookups only within addrconf.c when picking a source address,
> and never call ip6_route_output before source address has been
> populated.
> 
> Signed-off-by: Markus Stenberg <markus.stenberg@iki.fi>

Applied, but would like to see the more complete fix at some
point.
