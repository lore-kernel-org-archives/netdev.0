From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] net: sched: convert qdisc linked list to
 hashtable
Date: Fri, 08 Jul 2016 15:52:13 +0200
Message-ID: <1467985933.17638.54.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
	 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160414151813.GE3715@orbyte.nwl.cc>
	 <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
	 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5710E1C1.2090209@mojatatu.com>
	 <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
	 <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm>
	 <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm>
	 <20160708110717.GA13885@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jikos@kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160708110717.GA13885@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-07-08 at 13:07 +0200, Thomas Graf wrote:
> On 07/07/16 at 10:36pm, Jiri Kosina wrote:
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index f45929c..630838e 100644
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
> >  	unsigned int		num_tx_queues;
> >  	unsigned int		real_num_tx_queues;
> >  	struct Qdisc		*qdisc;
> > +	DECLARE_HASHTABLE	(qdisc_hash, 16);
> 
> This blows up net_device to an insane size: 64K * sizeof(struct
> hlist_head). Can we allocate this on demand for net_devices where
> it is actually needed? The majority of virtual devices won't need
> this. Doesn't have to be rhashtable, can still be fixed size but
> at least allocate it.


Jiri probably misread the API and should have used :

DECLARE_HASHTABLE	(qdisc_hash, 4);

Google has a very similar patch with 16 buckets, and it is 'good enough',
although we do not hit the qdisc_tree_reduce_backlog() penalty.
