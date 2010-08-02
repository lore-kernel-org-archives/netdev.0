From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/4] u32: use get_unaligned_be32
Date: Mon, 02 Aug 2010 23:55:17 +0100
Message-ID: <1280789717.5914.1.camel@achroite.uk.solarflarecom.com>
References: <20100802220030.991706005@vyatta.com>
	 <20100802220113.821018357@vyatta.com>
	 <AANLkTimNBA4E0-iX6fesYPch-N1TDgg2kD0r-tK5Mq7A@mail.gmail.com>
	 <20100802154505.46cfe94a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29029 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab0HBWzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 18:55:20 -0400
In-Reply-To: <20100802154505.46cfe94a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-02 at 15:45 -0700, Stephen Hemminger wrote:
> On Tue, 3 Aug 2010 06:34:59 +0800
> Changli Gao <xiaosuo@gmail.com> wrote:
> 
> > On Tue, Aug 3, 2010 at 6:00 AM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > > U32 classifier reads data from packet at a offset passed in from
> > > user space. The offset should be aligned, but it is unsafe practice
> > > to depend on values from userspace.
> > >
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > >
> > > --- a/net/sched/cls_u32.c       2010-08-01 11:21:06.945820852 -0700
> > > +++ b/net/sched/cls_u32.c       2010-08-01 11:24:55.257793848 -0700
> > > @@ -41,6 +41,7 @@
> > >  #include <net/netlink.h>
> > >  #include <net/act_api.h>
> > >  #include <net/pkt_cls.h>
> > > +#include <asm/unaligned.h>
> > >
> > >  struct tc_u_knode
> > >  {
> > > @@ -140,7 +141,7 @@ next_knode:
> > >                        data = skb_header_pointer(skb, toff, 4, &_data);
> > >                        if (!data)
> > >                                goto out;
> > > -                       if ((*data ^ key->val) & key->mask) {
> > > +                       if ((get_unaligned_be32(data) ^ key->val) & key->mask) {
> > 
> > be32()? I think it may break configuration.
> 
> The data pointer is be32 * already.

But get_unaligned_be32() converts to native byte order.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

