From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 3/5] vxlan: add ipv6 support
Date: Wed, 17 Apr 2013 17:57:20 +0800
Message-ID: <1366192640.700.3.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-4-git-send-email-amwang@redhat.com>
	 <CAF1J0HOYVCe-0MVE6-mxyjEOaEAWNR16Wpv7+CF6rxbEgBQ3GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757266Ab3DQJ5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 05:57:38 -0400
In-Reply-To: <CAF1J0HOYVCe-0MVE6-mxyjEOaEAWNR16Wpv7+CF6rxbEgBQ3GA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-17 at 11:15 +0300, Mike Rapoport wrote:
> On Wed, Apr 17, 2013 at 01:10:20PM +0800, Cong Wang wrote:
> >  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > @@ -42,6 +41,11 @@
> >  #include <net/inet_ecn.h>
> >  #include <net/net_namespace.h>
> >  #include <net/netns/generic.h>
> > +#if IS_ENABLED(CONFIG_IPV6)
> 
> It seems to me that some of the #ifdefs may be removed, especially on
> the rtnetlink path.

Which one? If you mean the one above, I know it can be removed, but it
can save some compile time if we have it.

> 
> > +#include <net/addrconf.h>
> > +#include <net/ip6_route.h>
> > +#include <net/ip6_tunnel.h>
> > +#endif
> >
...
> >
> > +	if (data[IFLA_VXLAN_REMOTE]) {
> > +		__be32 gaddr = nla_get_be32(data[IFLA_VXLAN_REMOTE]);
> > +		if (!IN_MULTICAST(ntohl(gaddr))) {
> > +			pr_debug("group address is not IPv4 multicast\n");
> > +			return -EADDRNOTAVAIL;
> > +		}
> > +	} else if (data[IFLA_VXLAN_REMOTE6]) {
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +		struct in6_addr gaddr;
> > +		nla_memcpy(&gaddr, data[IFLA_VXLAN_REMOTE6], sizeof(gaddr));
> > +		if (!ipv6_addr_is_multicast(&gaddr)) {
> > +			pr_debug("group address is not IPv6 multicast\n");
> > +			return -EADDRNOTAVAIL;
> > +		}
> > +#else
> > +		return -EPFNOSUPPORT;
> > +#endif
> > +	}
> 
> Adding back the test for multicast address contradicts the ability to
> use unicast as default remote destination.

Oops, it is definitely my mistake when handling the conflicts here.
Fixed now.

Thanks.
