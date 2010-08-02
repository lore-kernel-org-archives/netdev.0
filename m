From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/4] u32: use get_unaligned_be32
Date: Mon, 2 Aug 2010 15:45:05 -0700
Message-ID: <20100802154505.46cfe94a@nehalam>
References: <20100802220030.991706005@vyatta.com>
	<20100802220113.821018357@vyatta.com>
	<AANLkTimNBA4E0-iX6fesYPch-N1TDgg2kD0r-tK5Mq7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56476 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075Ab0HBWpI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 18:45:08 -0400
In-Reply-To: <AANLkTimNBA4E0-iX6fesYPch-N1TDgg2kD0r-tK5Mq7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Aug 2010 06:34:59 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> On Tue, Aug 3, 2010 at 6:00 AM, Stephen Hemminger <shemminger@vyatta.=
com> wrote:
> > U32 classifier reads data from packet at a offset passed in from
> > user space. The offset should be aligned, but it is unsafe practice
> > to depend on values from userspace.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > --- a/net/sched/cls_u32.c =A0 =A0 =A0 2010-08-01 11:21:06.945820852=
 -0700
> > +++ b/net/sched/cls_u32.c =A0 =A0 =A0 2010-08-01 11:24:55.257793848=
 -0700
> > @@ -41,6 +41,7 @@
> > =A0#include <net/netlink.h>
> > =A0#include <net/act_api.h>
> > =A0#include <net/pkt_cls.h>
> > +#include <asm/unaligned.h>
> >
> > =A0struct tc_u_knode
> > =A0{
> > @@ -140,7 +141,7 @@ next_knode:
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data =3D skb_header_=
pointer(skb, toff, 4, &_data);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!data)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto=
 out;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((*data ^ key->val=
) & key->mask) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((get_unaligned_be=
32(data) ^ key->val) & key->mask) {
>=20
> be32()? I think it may break configuration.

The data pointer is be32 * already.
