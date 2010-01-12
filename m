From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning
Date: Tue, 12 Jan 2010 10:13:06 -0800
Message-ID: <20100112101306.6a67c0a5@nehalam>
References: <20100112.000804.186755338.davem@davemloft.net>
	<20100112085633.GB6628@ff.dom.local>
	<20100112.014218.112731835.davem@davemloft.net>
	<20100112.025620.210305029.davem@davemloft.net>
	<20100112081513.0175d579@nehalam>
	<20100112180430.GA3355@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org,
	mbreuer@majjas.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50028 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943Ab0ALSNd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 13:13:33 -0500
In-Reply-To: <20100112180430.GA3355@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jan 2010 19:04:30 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Tue, Jan 12, 2010 at 08:15:13AM -0800, Stephen Hemminger wrote:
> > This code makes transmit path and transmit reset safer by:
> >   * adding memory barrier before checking available ring slots
> >   * reseting state of tx ring elements after free
> >   * seperate cleanup function from ring done function
> >   * removing mostly unused tx_next element  
> 
> Does this patch prevent re-enabling tx after netif_device_detach(),
> e.g. when sky2_detach() and sky2_tx_done() run at the same time on
> different cpus?
> 

Yes.
The napi is disabled during the detach so transmit completion can
not be done during that period.
