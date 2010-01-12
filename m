From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning
Date: Tue, 12 Jan 2010 19:24:47 +0100
Message-ID: <20100112182447.GB3355@del.dom.local>
References: <20100112.000804.186755338.davem@davemloft.net>
 <20100112085633.GB6628@ff.dom.local>
 <20100112.014218.112731835.davem@davemloft.net>
 <20100112.025620.210305029.davem@davemloft.net>
 <20100112081513.0175d579@nehalam>
 <20100112180430.GA3355@del.dom.local>
 <20100112101306.6a67c0a5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org,
	mbreuer@majjas.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:42093 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766Ab0ALSYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 13:24:54 -0500
Received: by fxm25 with SMTP id 25so9191fxm.21
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 10:24:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100112101306.6a67c0a5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 10:13:06AM -0800, Stephen Hemminger wrote:
> On Tue, 12 Jan 2010 19:04:30 +0100
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > On Tue, Jan 12, 2010 at 08:15:13AM -0800, Stephen Hemminger wrote:
> > > This code makes transmit path and transmit reset safer by:
> > >   * adding memory barrier before checking available ring slots
> > >   * reseting state of tx ring elements after free
> > >   * seperate cleanup function from ring done function
> > >   * removing mostly unused tx_next element  
> > 
> > Does this patch prevent re-enabling tx after netif_device_detach(),
> > e.g. when sky2_detach() and sky2_tx_done() run at the same time on
> > different cpus?
> > 
> 
> Yes.
> The napi is disabled during the detach so transmit completion can
> not be done during that period.

Could you point me where exactly the napi is disabled, probably I
missed this?

Jarek P.
