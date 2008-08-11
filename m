From: John Gumb <john.gumb@tandberg.com>
Subject: Re: OOPS, ip -f inet6 route get fec0::1,
	linux-2.6.26,	ip6_route_output, rt6_fill_node+0x175
Date: Mon, 11 Aug 2008 08:41:27 +0100
Message-ID: <1218440487.32543.7.camel@ukdev-lin-jag>
References: <9F6ACAE02B6DD040A1E259977622CFDB033590C3@oslexcp1.eu.tandberg.int>
	 <20080807203748.GA5196@martell.zuzino.mipt.ru>  <489BD227.6000209@hp.com>
Reply-To: john.gumb@tandberg.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751637AbYHKHln@vger.kernel.org>
In-Reply-To: <489BD227.6000209@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

looks good to me.

thanks people.

John
On Fri, 2008-08-08 at 00:57 -0400, Brian Haley wrote:
> Alexey Dobriyan wrote:
> > On Thu, Aug 07, 2008 at 07:00:56PM +0200, John Gumb wrote:
> >> Scenario: no ipv6 default route set.
> > 
> >> # ip -f inet6 route get fec0::1
> >>
> >> BUG: unable to handle kernel NULL pointer dereference at 00000000
> >> IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
> >> EIP is at rt6_fill_node+0x175/0x3b0
> > 
> > 0xffffffff80424dd3 is in rt6_fill_node (net/ipv6/route.c:2191).
> > 2186                    } else
> > 2187    #endif
> > 2188                            NLA_PUT_U32(skb, RTA_IIF, iif);
> > 2189            } else if (dst) {
> > 2190                    struct in6_addr saddr_buf;
> > 2191      ====>         if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
> > 					       ^^^^^^^^^^^^^^^^^^^^^^^^
> > 					       		NULL
> > 
> > 2192                                           dst, 0, &saddr_buf) == 0)
> > 2193                            NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
> > 2194            }
> 
> The commit that changed this can't be reverted easily, but the patch 
> below works for me.
> 
> Fix NULL de-reference in rt6_fill_node() when there's no IPv6 input 
> device present in the dst entry.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> 
