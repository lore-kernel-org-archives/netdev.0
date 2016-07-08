From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH v2] net: sched: convert qdisc linked list to hashtable
Date: Fri, 8 Jul 2016 13:07:17 +0200
Message-ID: <20160708110717.GA13885@pox.localdomain>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160414151813.GE3715@orbyte.nwl.cc>
 <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <5710E1C1.2090209@mojatatu.com>
 <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm>
 <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38526 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754262AbcGHLHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 07:07:20 -0400
Received: by mail-wm0-f46.google.com with SMTP id n127so10731201wme.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 04:07:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/16 at 10:36pm, Jiri Kosina wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f45929c..630838e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -52,6 +52,7 @@
>  #include <uapi/linux/netdevice.h>
>  #include <uapi/linux/if_bonding.h>
>  #include <uapi/linux/pkt_cls.h>
> +#include <linux/hashtable.h>
>  
>  struct netpoll_info;
>  struct device;
> @@ -1778,6 +1779,7 @@ struct net_device {
>  	unsigned int		num_tx_queues;
>  	unsigned int		real_num_tx_queues;
>  	struct Qdisc		*qdisc;
> +	DECLARE_HASHTABLE	(qdisc_hash, 16);

This blows up net_device to an insane size: 64K * sizeof(struct
hlist_head). Can we allocate this on demand for net_devices where
it is actually needed? The majority of virtual devices won't need
this. Doesn't have to be rhashtable, can still be fixed size but
at least allocate it.
