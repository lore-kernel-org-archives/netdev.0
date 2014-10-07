From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Quota in __qdisc_run() (was: qdisc: validate skb without
 holding lock)
Date: Tue, 7 Oct 2014 17:26:06 +0200
Message-ID: <20141007172606.0da50a60@redhat.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	<1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141003.153645.72976986956341944.davem@davemloft.net>
	<1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141007093441.35ce3a02@redhat.com>
	<1412686038.11091.111.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141007153050.792c9743@redhat.com>
	<1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk,
	brouer@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754110AbaJGP1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 11:27:04 -0400
In-Reply-To: <1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2014 16:43:33 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Tue, Oct 7, 2014, at 15:30, Jesper Dangaard Brouer wrote:
[...]
> > 
> > The basic idea is we want keep/restore the quota fairness between
> > qdisc's , that we sort of broke with commit 5772e9a346 ("qdisc: bulk
> > dequeue support for qdiscs with TCQ_F_ONETXQUEUE").
> > 
[...]
> 
> This needs to be:
> 
> do
>    ...
> while ((iskb = iskb->next))

Check, testing with this update, now.

My netperf-wrapper test with GSO=off TSO=off, looks much more stable at
keeping the 10G link fully utilized.  Before, without this patch, I
could not get stable results at 10G with GSO=off TSO=off.  Think this
really does address the fairness (I didn't think I would be able to
measure it).

The other cases (GSO=on,TSO=off) and (GSO=on,TSO=on) looks the same.
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
