From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v5 16/16] net: sched: drop ingress qdisc lock
Date: Fri, 12 Sep 2014 18:33:57 -0700
Message-ID: <1410572037.7106.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
	 <20140912163519.19588.54966.stgit@nitbit.x32>
	 <1410566188.7106.120.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:37845 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaIMBd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 21:33:59 -0400
Received: by mail-pa0-f44.google.com with SMTP id kx10so2444202pab.17
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 18:33:59 -0700 (PDT)
In-Reply-To: <1410566188.7106.120.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 16:56 -0700, Eric Dumazet wrote:
> On Fri, 2014-09-12 at 09:35 -0700, John Fastabend wrote:
> > After the previous patches to make the filters RCU safe and
> > support per cpu counters we can drop the qdisc lock around
> > the ingress qdisc hook.
> > 
> > This is possible because the ingress qdisc is a very basic
> > qdisc and only updates stats and runs tc_classify. Its the
> > simplest qdiscs we have.
> > 
> > In order for the per-cpu counters to get invoked the
> > ingress qdisc must set the LLQDISC flag. We could use per-cpu
> > counters on all counters but it is only necessary when the
> > qdisc lock is not held.
> > 
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> 

BTW, it might be time to revive the multiqueue patch for IFB,
Changli Gao worked on this 5 years ago, but work was not completed.
