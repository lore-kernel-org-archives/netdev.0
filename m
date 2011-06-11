From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 13/13] ixgbe: use per NUMA node lock for FCoE DDP
Date: Sat, 11 Jun 2011 07:42:11 +0200
Message-ID: <1307770931.2872.70.camel@edumazet-laptop>
References: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307761341-5267-14-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307769482.2872.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Vasu Dev <vasu.dev@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45129 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab1FKFmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 01:42:15 -0400
Received: by wya21 with SMTP id 21so2258049wya.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 22:42:14 -0700 (PDT)
In-Reply-To: <1307769482.2872.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 11 juin 2011 =C3=A0 07:18 +0200, Eric Dumazet a =C3=A9crit :
> >  /**
> > diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixg=
be_fcoe.h
> > index d876e7a..8618892 100644
> > --- a/drivers/net/ixgbe/ixgbe_fcoe.h
> > +++ b/drivers/net/ixgbe/ixgbe_fcoe.h
> > @@ -69,6 +69,7 @@ struct ixgbe_fcoe {
> >  	struct pci_pool **pool;
> >  	atomic_t refcnt;
> >  	spinlock_t lock;
> > +	struct spinlock **node_lock;
>=20
> Wont this read_mostly pointer sits in often modified cache line ?
>=20
> >  	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];
> >  	unsigned char *extra_ddp_buffer;
> >  	dma_addr_t extra_ddp_buffer_dma;
>=20

This patch seems overkill to me, have you tried the more simple way I
did in commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527
(net: add additional lock to qdisc to increase throughput )

(remember you must place ->busylock in a separate cache line, to not
slow down the two cpus that have access to ->lock)

struct ixgbe_fcoe could probably be more carefuly reordered to lower
false sharing

I kindly ask you guys provide actual perf numbers between

1) before any patch
2) After your multilevel per numanode locks
3) A more simple way (my suggestion of adding a single 'busylock')

Thanks


