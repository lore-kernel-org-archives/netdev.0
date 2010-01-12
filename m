From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v2)
Date: Tue, 12 Jan 2010 11:23:14 -0800
Message-ID: <20100112112314.6d3b37d0@nehalam>
References: <20100112.000804.186755338.davem@davemloft.net>
	<20100112085633.GB6628@ff.dom.local>
	<20100112.014218.112731835.davem@davemloft.net>
	<20100112.025620.210305029.davem@davemloft.net>
	<20100112081513.0175d579@nehalam>
	<20100112180430.GA3355@del.dom.local>
	<20100112101306.6a67c0a5@nehalam>
	<20100112182447.GB3355@del.dom.local>
	<20100112104945.462cf205@nehalam>
	<20100112191611.GC3355@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org,
	mbreuer@majjas.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53282 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753407Ab0ALTXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 14:23:31 -0500
In-Reply-To: <20100112191611.GC3355@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jan 2010 20:16:11 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> > 
> > What is supposed to happen:
> >   * restart sky2_restart calls napi_disable while cleaning  
> 
> Yes, but it's after the detach; similarly to sky2_suspend().
> (I'm not sure how safe vs such re-enabling is sky2_set_ringparam().

set_ringparam happens under rtnl_lock() so reset and ringparams can't
conflict.

> 
> >   * dev_close we can't call napi_disable() because of two ports
> >     sharing same NAPI, so napi_synchronize() is used to make sure that
> >     any NAPI running on other CPU has completed.  
> 
> So it seems still endangered.

It was but not in revised v2 patch.
