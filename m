From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Fri, 25 Nov 2011 08:37:16 +0530
Message-ID: <OF86B15006.7F4BE3FB-ON65257953.00104C3E-65257953.0010EFCA@in.ibm.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com> <20111124095902.GD14491@redhat.com> <4ECE18D5.3060605@redhat.com> <20111124103449.GA16031@redhat.com> <4ECE3F0D.3090908@redhat.com> <20111124161430.GC26770@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: arnd@arndb.de, davem@davemloft.net, jasowang <jasowang@redhat.com>,
	levinsasha928@gmail.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:46779 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab1KYDFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 22:05:09 -0500
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Fri, 25 Nov 2011 08:35:04 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAP3516g4657230
	for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 08:35:01 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAP350f8029803
	for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 08:35:01 +0530
In-Reply-To: <20111124161430.GC26770@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 11/24/2011 09:44:31 PM:

> > As far as I can see, ixgbe binds queues to physical cpu, so let
consider:
> >
> > vhost thread transmits packets of flow A on processor M
> > during packet transmission, ixgbe driver programs the card to
> > deliver the packet of flow A to queue/cpu M through flow director
> > (see ixgbe_atr())
> > vhost thread then receives packet of flow A with from M
> > ...
> > vhost thread transmits packets of flow A on processor N
> > ixgbe driver programs the flow director to change the delivery of
> > flow A to queue N ( cpu N )
> > vhost thread then receives packet of flow A with from N
> > ...
> >
> > So, for a single flow A, we may get different queue mappings. Using
> > rxhash instead may solve this issue.
>
> Or better, transmit a single flow from a single vhost thread.
>
> If packets of a single flow get spread over different CPUs,
> they will get reordered and things are not going to work well.

My testing so far shows that guest sends on (e.g.) TXQ#2
only, which is handled by vhost#2; and this doesn't change
for the entire duration of the test. Incoming keeps
changing for different packets but become same with
this patch. To iterate, I have not seen the following:

"
vhost thread transmits packets of flow A on processor M
...
vhost thread transmits packets of flow A on processor N
"

- KK
