From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [RFC PATCH v3] net: sched: convert qdisc linked list to
 hashtable
Date: Wed, 13 Jul 2016 15:47:54 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1607131547110.24757@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm> <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com> <20160414151813.GE3715@orbyte.nwl.cc> <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm> <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <5710E1C1.2090209@mojatatu.com> <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm> <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm> <alpine.LNX.2.00.1607111557080.24757@cbobk.fhfr.pm>
 <CAM_iQpV0QskOZd9A5LCGPsFC0nunyOmWNcExdt1gi1mgL0dB0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39629 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbcGMNst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 09:48:49 -0400
In-Reply-To: <CAM_iQpV0QskOZd9A5LCGPsFC0nunyOmWNcExdt1gi1mgL0dB0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jul 2016, Cong Wang wrote:

> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index f45929c..0b5c172e 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -52,6 +52,7 @@
> >  #include <uapi/linux/netdevice.h>
> >  #include <uapi/linux/if_bonding.h>
> >  #include <uapi/linux/pkt_cls.h>
> > +#include <linux/hashtable.h>
> >
> >  struct netpoll_info;
> >  struct device;
> > @@ -1778,6 +1779,7 @@ struct net_device {
> >         unsigned int            num_tx_queues;
> >         unsigned int            real_num_tx_queues;
> >         struct Qdisc            *qdisc;
> > +       DECLARE_HASHTABLE       (qdisc_hash, 4);
> >         unsigned long           tx_queue_len;
> >         spinlock_t              tx_global_lock;
> >         int                     watchdog_timeo;
> 
> Should it be surrounded by CONFIG_NET_SCHED?
> To save several bytes for !CONFIG_NET_SCHED case.

Makes sense. I'll wait a bit for more feedback (if there is any) before 
including this in potential v4.

Thanks,

-- 
Jiri Kosina
SUSE Labs
