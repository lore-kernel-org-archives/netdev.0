From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v5 1/2] geneve: implement support for IPv6-based tunnels
Date: Fri, 23 Oct 2015 09:38:16 -0400
Message-ID: <20151023133815.GB23952@tuxdriver.com>
References: <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
 <1445543136-8265-1-git-send-email-linville@tuxdriver.com>
 <5629BC31.5070300@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44824 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbbJWNp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:45:28 -0400
Content-Disposition: inline
In-Reply-To: <5629BC31.5070300@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 01:48:49PM +0900, YOSHIFUJI Hideaki wrote:
> Hi,
> 
> John W. Linville wrote:
> > NOTE: Link-local IPv6 addresses for remote endpoints are not supported,
> > since the driver currently has no capacity for binding a geneve
> > interface to a specific link.
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > ---
> > v5:
> > - wrap declaration of sock6 in geneve_dev with IS_ENABLED(CONFIG_IPV6)
> > - remove superfluous '!!' when assigning geneve->collect_md to bool
> > - use skb_scrub_packet in IPv4 tx path as well 
> > - check for NULL ip_tunnel_info pointer in geneve[6]_xmit_skb
> > - use ipv6_addr_equal for comparing IPv6 addresses
> > - more use of IS_ENABLED(CONFIG_IPV6) for preserving build integrity
> > - reject link-local ipv6 address for remote tunnel endpoint
> :
> 
> > @@ -870,15 +1147,35 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
> :
> > +
> > +		if (ipv6_addr_type(&remote.sin6.sin6_addr) &
> > +		    IPV6_ADDR_LINKLOCAL)
> > +			netdev_dbg(dev, "link-local remote is unsupported\n");
> > +			return -EINVAL;
> > +	}
> > +
> 
> This always returns -EINVAL; {} is missing.

Yikes!  I posted the wrong patch...good eyes!

I will repost...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
