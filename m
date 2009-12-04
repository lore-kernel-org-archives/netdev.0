From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] ipv6: Fix "waiting for %s to become free" hang
Date: Fri, 4 Dec 2009 17:45:47 +0530
Message-ID: <OF5EE0E5C1.4524B513-ON65257682.00420FFC-65257682.00425E41@in.ibm.com>
References: <20091204112734.24535.86096.sendpatchset@localhost.localdomain> <4B18F54A.8000106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:38201 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000AbZLDMEw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 07:04:52 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id nB4BhSPl017270
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 17:13:28 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB4C4vew2719776
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 17:34:57 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB4C4vAo019160
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 23:04:57 +1100
In-Reply-To: <4B18F54A.8000106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Eric Dumazet <eric.dumazet@gmail.com>
>
> Re: [PATCH] ipv6: Fix "waiting for %s to become free" hang
>
> Krishna Kumar a =E9crit :
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> >
> > (From code-walkthrough, and untested)
> >
> > Fix "waiting for %s to become free" hang. dev has an
> > extra hold (by ip6mr_reg_vif) which was not dropped
> > before calling unregister_netdevice.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
> >  net/ipv6/ip6mr.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff -ruNp org/net/ipv6/ip6mr.c new/net/ipv6/ip6mr.c
> > --- org/net/ipv6/ip6mr.c   2009-12-04 16:08:07.000000000 +0530
> > +++ new/net/ipv6/ip6mr.c   2009-12-04 16:09:56.000000000 +0530
> > @@ -648,8 +648,8 @@ static int mif6_add(struct net *net, str
> >           return -ENOBUFS;
> >        err =3D dev_set_allmulti(dev, 1);
> >        if (err) {
> > -         unregister_netdevice(dev);
> >           dev_put(dev);
> > +         unregister_netdevice(dev);
> >           return err;
> >        }
> >        break;
>
> This changes nothing, since we hold rtnl at this point.
>
> unregister_netdevice() only queues the device (net_set_todo()) in a l=
ist.
>
> And we process this list later, when renl_unlock() is finally called.

Yes, you are right. I sent the patch on my memory of unregister_netdev,
which gets
the rtnl and drops it, and that would have caused this problem. Please =
drop
the patch.

thanks,

- KK

