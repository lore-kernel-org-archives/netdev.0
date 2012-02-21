From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
Date: Mon, 20 Feb 2012 20:03:18 -0800
Message-ID: <1329796998.13141.26.camel@localhost.localdomain>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>
	 <1329519726-25763-2-git-send-email-aliguori@us.ibm.com>
	 <20120219144145.GA16620@redhat.com>
	 <OFC071CE44.FE2F733D-ON862579AA.0055FCA0-862579AA.0057082B@us.ibm.com>
	 <20120220192708.GA18308@redhat.com> <4F42A2FB.7000501@us.ibm.com>
	 <20120220210005.GA19278@redhat.com>
	 <1329786250.13141.9.camel@localhost.localdomain>
	 <20120221032147.GB2502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <aliguori@us.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>, netdev@vger.kernel.org,
	Cristian Viana <vianac@br.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:45112 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab2BUFmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 00:42:53 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Mon, 20 Feb 2012 22:42:52 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 475E819D8048
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 22:42:29 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1L5gXxW152896
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 22:42:33 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1L5gWKv019951
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 22:42:33 -0700
In-Reply-To: <20120221032147.GB2502@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-21 at 05:21 +0200, Michael S. Tsirkin wrote:
> On Mon, Feb 20, 2012 at 05:04:10PM -0800, Shirley Ma wrote:
> > On Mon, 2012-02-20 at 23:00 +0200, Michael S. Tsirkin wrote:
> > > 
> > > The point was really to avoid scheduler overhead
> > > as with tcp, tx and rx tend to run on the same cpu.
> > 
> > We have tried different approaches in the past, like splitting vhost
> > thread to separate TX, RX threads; create per cpu vhost thread
> instead
> > of creating per VM per virtio_net vhost thread... 
> > 
> > We think per cpu vhost thread is a better approach based on the data
> we
> > have collected. It will reduce both vhost resource and scheduler
> > overhead. It will not depend on host scheduler, has less various.
> The
> > patch is under testing, we hope we can post it soon.
> > 
> > Thanks
> > Shirley
> 
> Yes, great, this is definitely interesting. I actually started with
> a per-cpu one - it did not perform well but I did not
> figure out why, switching to a single thread fixed it
> and I did not dig into it.

The patch includes per cpu vhost thread & vhost NUMA aware scheduling

It is very interesting. We are collecting performance data with
different workloads (streams, request/response) related to which VCPU
runs on which CPU, which vhost cpu thread is being scheduled, and which
NIC TX/RX queues is being used. The performance were different when
using different vhost scheduling approach for both TX/RX worker. The
results seems pretty good: like 60 UDP_RRs, the results event more than
doubled in our lab. However the TCP_RRs results couldn't catch up
UDP_RRs.

Thanks
Shirley
