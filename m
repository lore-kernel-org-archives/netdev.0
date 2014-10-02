From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Thu, 02 Oct 2014 13:06:53 -0700
Message-ID: <1412280413.22242.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412267647.22242.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1410022231100.3225@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58239 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbaJBUGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 16:06:54 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so3300400pad.5
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 13:06:54 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1410022231100.3225@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-02 at 22:34 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Thu, 2 Oct 2014, Eric Dumazet wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Testing xmit_more support with netperf and connected UDP sockets,
> > I found strange dst refcount false sharing.
> > 
> > Current handling of IFF_XMIT_DST_RELEASE is not optimal.
> > 
> > dropping dst in validate_xmit_skb() is certainly too late in case
> > packet was queued by cpu X but dequeued by cpu Y
> > 
> > The logical point to take care of drop/force is in __dev_queue_xmit()
> > before even taking qdisc lock.
> 
> 	Does it hurt skb_dst usage in net/sched/, for example,
> dst->tclassid in net/sched/cls_route.c ?

Hmm good point...

Then, if a qdisc like that is used, I guess we can remove
IFF_XMIT_DST_RELEASE from dev->priv_flags

Maybe I should add a dev->dst_are_needed counter, instead using a flag.

Thanks
