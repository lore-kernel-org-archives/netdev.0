From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v2)
Date: Tue, 12 Jan 2010 20:50:04 +0100
Message-ID: <20100112195004.GD3355@del.dom.local>
References: <20100112085633.GB6628@ff.dom.local>
 <20100112.014218.112731835.davem@davemloft.net>
 <20100112.025620.210305029.davem@davemloft.net>
 <20100112081513.0175d579@nehalam>
 <20100112180430.GA3355@del.dom.local>
 <20100112101306.6a67c0a5@nehalam>
 <20100112182447.GB3355@del.dom.local>
 <20100112104945.462cf205@nehalam>
 <20100112191611.GC3355@del.dom.local>
 <20100112112314.6d3b37d0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org,
	mbreuer@majjas.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:35643 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722Ab0ALTuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 14:50:10 -0500
Received: by fxm25 with SMTP id 25so47809fxm.21
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 11:50:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100112112314.6d3b37d0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 11:23:14AM -0800, Stephen Hemminger wrote:
> On Tue, 12 Jan 2010 20:16:11 +0100
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > > 
> > > What is supposed to happen:
> > >   * restart sky2_restart calls napi_disable while cleaning  
> > 
> > Yes, but it's after the detach; similarly to sky2_suspend().
> > (I'm not sure how safe vs such re-enabling is sky2_set_ringparam().
> 
> set_ringparam happens under rtnl_lock() so reset and ringparams can't
> conflict.

I didn't mean reset. I meant tx (dev_queue_xmit()) during ringparams.

> 
> > 
> > >   * dev_close we can't call napi_disable() because of two ports
> > >     sharing same NAPI, so napi_synchronize() is used to make sure that
> > >     any NAPI running on other CPU has completed.  
> > 
> > So it seems still endangered.
> 
> It was but not in revised v2 patch.

Sorry, I meant sky2_down() (except in dev_close()).

Jarek P.
