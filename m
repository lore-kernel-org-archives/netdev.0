From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Mar 9 (netfilter)
Date: Sun, 11 Mar 2012 17:58:02 +0100
Message-ID: <20120311165802.GB27265@1984>
References: <giupeu1.0f6dad72b5ddb117e753f5f660263a5d@obelix.schillstrom.com>
 <20120311165630.GA27265@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45786 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753566Ab2CKQ6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Mar 2012 12:58:05 -0400
Content-Disposition: inline
In-Reply-To: <20120311165630.GA27265@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hans,

On Sun, Mar 11, 2012 at 05:14:01PM +0100, Hans Schillstrom wrote:
> >Perhaps I'm missing anything but either way (IPv6 as module or
> >built-in) the symbol is still defined. With my patch applied, xt_LOG
> >now depends on IP6_NF_IPTABLES, which depends on IPV6.
> >
> >Moreover we've got other xt_ target and matches that contain both IPv4
> >and IPv6 support that don't require this.
> >
> >Let me know.
> 
> if you compile ipv6 as a module and xt_LOG as builtin (=y)  there is a missing ref to  `ip6t_ext_hdr' at link time ...

ip6t_ext_hdr is defined by ip6_tables:

net/ipv6/netfilter/ip6_tables.c:ip6t_ext_hdr(u8 nexthdr)

AFAICS the dependency should rely on CONFIG_IP6_NF_IPTABLES.

An alternative is to define ip6t_ext_hdr as static inline in
include/linux/netfilter_ipv6/ip6_tables.h, it's fairly small and it's
invoked in the typical packet path if this LOG is used.

> What I did was to resolve that issue i.e. force xt_LOG to be a module if ipv6 is a module

Thanks for reporting this.
