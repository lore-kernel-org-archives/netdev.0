From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC Patch net-next] vxlan: add ipv6 support
Date: Thu, 28 Feb 2013 10:33:11 +0000
Message-ID: <20130228103311.GC7558@casper.infradead.org>
References: <1362031286-23295-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48886 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab3B1KdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 05:33:13 -0500
Content-Disposition: inline
In-Reply-To: <1362031286-23295-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/13 at 02:01pm, Cong Wang wrote:
> WARNING: This is just an RFC patch, it only compiles!!
> 
> This patch adds IPv6 support to vxlan device, as the new version
> RFC already mentioned it:
> 
> 	http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-03
> 
> I am not sure if the following trick will work:
> 
> 	+       if (nla_len(nla) == sizeof(__be32)) {
> 	+               ip->ip4 = nla_get_be32(nla);
> 	+               ip->proto = htons(ETH_P_IP);
> 	+       }
> 	+#if IS_ENABLED(CONFIG_IPV6)
> 	+       else if (nla_len(nla) == sizeof(struct in6_addr)) {
> 	+               nla_memcpy(&ip->ip6, nla, sizeof(struct in6_addr));
> 	+               ip->proto = htons(ETH_P_IPV6);
> 	+       }
> 	+#endif
> 
> otherwise we have to introduce some new netlink attributes for
> IPv6 addresses? Any comments?

How about setting ndm_family to AF_INET6 and parse NDA_DST based on
that?

Assuming that nla_len(NDA_DST) > 4 == ip6 is a bit weak as like with
any Netlink attribute we only ever enforce a minimum length and never
a maximum or exact length.
