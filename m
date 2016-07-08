From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [RFC PATCH v2] net: sched: convert qdisc linked list to
 hashtable
Date: Fri, 8 Jul 2016 11:02:35 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1607081058230.24757@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>   <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>   <20160414151813.GE3715@orbyte.nwl.cc>   <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>  
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>   <5710E1C1.2090209@mojatatu.com>  <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>  <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm>  <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm>
 <1467967838.17638.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33182 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbcGHJCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 05:02:38 -0400
In-Reply-To: <1467967838.17638.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jul 2016, Eric Dumazet wrote:

> > diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> > index fdc9de2..0f70ecc 100644
> > --- a/net/ipv6/ip6_gre.c
> > +++ b/net/ipv6/ip6_gre.c
> > @@ -62,11 +62,11 @@ module_param(log_ecn_error, bool, 0644);
> >  MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
> >  
> >  #define HASH_SIZE_SHIFT  5
> > -#define HASH_SIZE (1 << HASH_SIZE_SHIFT)
> > +#define __HASH_SIZE (1 << HASH_SIZE_SHIFT)
> 
> __ prefix is mostly used for functions having some kind of
> shells/helpers.
> 
> I would rather use IP6_GRE_HASH_SIZE or something which has lower
> chances of being used elsewhere.

Alright, makes sense, will do this in v3.

> @@ -732,6 +730,8 @@ static void attach_default_qdiscs(struct net_device *dev)
> >  			qdisc->ops->attach(qdisc);
> >  		}
> >  	}
> > +	if (dev->qdisc)
> > +		qdisc_hash_add(dev->qdisc);
> >  }
> >  
> 
> I do not understand this addition, could you comment on it ?

With linked lists, assigning to struct net_device's Qdisc pointer is 
enough to "initialize" the linked list and have it contain one (root) 
item. With hashtable, this is not the case, it needs to be explicitly 
added.

Hmm, dev_init_scheduler() (and perhaps also dev_shutdown()) would possibly 
need similar treatment in order to have accurate data there 100% of the 
time even during initialization.

-- 
Jiri Kosina
SUSE Labs
