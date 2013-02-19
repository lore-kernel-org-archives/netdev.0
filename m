From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Tue, 19 Feb 2013 08:21:49 -0800
Message-ID: <1361290909.19353.140.camel@edumazet-glaptop>
References: <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 (sfid-20130219_061917_530878_1ED7A14C) <1361268221.8553.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc@merlins.org>, David Miller <davem@davemloft.net>,
	Larry.Finger@lwfinger.net, bhutchings@solarflare.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:51870 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758244Ab3BSQVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 11:21:53 -0500
In-Reply-To: <1361268221.8553.1.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 11:03 +0100, Johannes Berg wrote:
> On Mon, 2013-02-18 at 21:17 -0800, Eric Dumazet wrote:
> 
> > > chrome: page allocation failure: order:1, mode:0x4020
> > > Pid: 8730, comm: chrome Tainted: G           O 3.7.8-amd64-preempt-20121226-fixwd #1
> > > Call Trace:
> > >  <IRQ>  [<ffffffff810d5f38>] warn_alloc_failed+0x117/0x12c
> 
> > You could try to load iwlwifi with amsdu_size_8K set to 0 (disable)
> > 
> > It should hopefully use order-0 pages
> 
> It will, do that then, unfortunately it can't switch at runtime because
> it advertised this support to the access point or clients.

What are the drawbacks of setting amsdu_size_8K to 0 by default ?

Alternative would be :

- As long as we cant allocate order-1 pages (to refill the RX ring),
copy incoming frames into order-0 pages, so that order-1 pages are still
available for the NIC.
