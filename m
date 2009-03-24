From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] netconsole: fix BUG during net device "upping"
Date: Tue, 24 Mar 2009 08:22:14 +0000
Message-ID: <20090324082214.GA4776@ff.dom.local>
References: <20090322.212107.55546529.davem@davemloft.net> <20090323080455.GA4976@ff.dom.local> <20090323.010541.94308473.davem@davemloft.net> <20090323081158.GB4976@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com, marcin.slusarz@gmail.com, netdev@vger.kernel.org,
	k-keiichi@bx.jp.nec.com, stable@kernel.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f208.google.com ([209.85.217.208]:52943 "EHLO
	mail-gx0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346AbZCXIWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 04:22:25 -0400
Content-Disposition: inline
In-Reply-To: <20090323081158.GB4976@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2009 at 08:11:58AM +0000, Jarek Poplawski wrote:
> On Mon, Mar 23, 2009 at 01:05:41AM -0700, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Mon, 23 Mar 2009 08:04:55 +0000
> > 
> > > What is the rationale of this decision? printk is a basic tool,
> > > especially designed to work in as many places as possible, and
> > > netconsole is rather something secondary (sorry Matt)?!
> > 
> > And this basic tool cannot work from the drivers ->open() method.
> 
> And in any function used in the drivers ->open(). BTW, with Marcin's
> patch it can...

And from any function called anywhere on another cpu while driver's
->open() is running.

BTW, I've had a look at this and it seems the main problem is
netif_tx_stopped() isn't handled properly by the driver(s).

Jarek P.
