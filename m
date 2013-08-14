From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCHv2 net-next] 6lowpan: handle only real link-local addresses
Date: Wed, 14 Aug 2013 13:29:04 +0200
Message-ID: <20130814112903.GB1704@x61s.8.8.8.8>
References: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
 <20130814110821.GH16264@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:42890 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab3HNLZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 07:25:12 -0400
Received: by mail-ee0-f51.google.com with SMTP id c1so4761896eek.24
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 04:25:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130814110821.GH16264@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

On Wed, Aug 14, 2013 at 01:08:21PM +0200, Hannes Frederic Sowa wrote:
> On Wed, Aug 14, 2013 at 01:01:07PM +0200, Alexander Aring wrote:
> > diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
> > index 4b8f917..61f0ce9 100644
> > --- a/net/ieee802154/6lowpan.h
> > +++ b/net/ieee802154/6lowpan.h
> > @@ -83,8 +83,11 @@
> >  #define ipaddr_prefixcmp(addr1, addr2, length) \
> >  	(memcmp(addr1, addr2, length >> 3) == 0)
> >  
> > -/* local link, i.e. FE80::/10 */
> > -#define is_addr_link_local(a) (((a)->s6_addr16[0]) == htons(0xFE80))
> > +/* link-local, i.e. FE80::/64 */
> > +#define is_addr_link_local(a) (((a)->s6_addr16[0]) == htons(0xFE80) &&	\
> > +		(((a)->s6_addr16[1]) == 0) &&	\
> > +		(((a)->s6_addr16[2]) == 0) &&	\
> > +		(((a)->s6_addr16[3]) == 0))
> >  
> 
> Can't you use ipv6_addr_type(a)&IPV6_ADDR_LINKLOCAL?
>
Of course, thanks for this hint I will take this on the list to change
it for checking for a multicast address, too.


I looked in the implementation of ipv6_addr_type and some little thing
confusing me.
A local-link address is FE80::/64, but the __ipv6_addr_type function
checks for FE80::/32.

-- snip
...
__be32 st;
st = addr->s6_addr32[0];
...
if ((st & htonl(0xFFC00000)) == htonl(0xFE800000))
	return ...
-- end snip


Is there some (addr->s6_addr32[1] == 0) check which I don't see?

Regards
Alex
