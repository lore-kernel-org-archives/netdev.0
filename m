From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next] vxlan: add ipv6 support
Date: Fri, 01 Mar 2013 11:31:19 +0800
Message-ID: <1362108679.31103.3.camel@cr0>
References: <1362031286-23295-1-git-send-email-amwang@redhat.com>
	 <20130228103311.GC7558@casper.infradead.org> <512FC71D.8080508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750Ab3CADbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 22:31:41 -0500
In-Reply-To: <512FC71D.8080508@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-28 at 16:07 -0500, Vlad Yasevich wrote:
> On 02/28/2013 05:33 AM, Thomas Graf wrote:
> > On 02/28/13 at 02:01pm, Cong Wang wrote:
> >> WARNING: This is just an RFC patch, it only compiles!!
> >>
> >> This patch adds IPv6 support to vxlan device, as the new version
> >> RFC already mentioned it:
> >>
> >> 	http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-03
> >>
> >> I am not sure if the following trick will work:
> >>
> >> 	+       if (nla_len(nla) == sizeof(__be32)) {
> >> 	+               ip->ip4 = nla_get_be32(nla);
> >> 	+               ip->proto = htons(ETH_P_IP);
> >> 	+       }
> >> 	+#if IS_ENABLED(CONFIG_IPV6)
> >> 	+       else if (nla_len(nla) == sizeof(struct in6_addr)) {
> >> 	+               nla_memcpy(&ip->ip6, nla, sizeof(struct in6_addr));
> >> 	+               ip->proto = htons(ETH_P_IPV6);
> >> 	+       }
> >> 	+#endif
> >>
> >> otherwise we have to introduce some new netlink attributes for
> >> IPv6 addresses? Any comments?
> >
> > How about setting ndm_family to AF_INET6 and parse NDA_DST based on
> > that?
> >
> 
> Not sure if you can do that without registering your own fdb netlink 
> handler.  rtnl_fdb_add is registered for PF_BRIDGE family.

Yeah...

> 
> You could do that, or use NDA_DST similar to how neighbor table uses it.
> There the data inside of NDA_DST holds an address family and other data.
> 

The data inside NDA_DST in neighbor table is the IP address used as a
key:

        if (nla_put(skb, NDA_DST, neigh->tbl->key_len,
neigh->primary_key))
                goto nla_put_failure;

there is not address family inside it.

Thanks.
