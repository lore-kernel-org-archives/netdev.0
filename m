From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Tue, 19 Feb 2013 08:36:49 -0800
Message-ID: <1361291809.19353.145.camel@edumazet-glaptop>
References: <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 <1361268221.8553.1.camel@jlt4.sipsolutions.net>
	 <20130219161830.GD21764@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:41886 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758355Ab3BSQgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 11:36:54 -0500
In-Reply-To: <20130219161830.GD21764@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 08:18 -0800, Marc MERLIN wrote:

> 
> Forgive the newbie question: would the inability to get pages cause
> interrupts to be disabled or at least something that would stop the mouse
> cursor and the keyboard from working?
> 

Maybe these things also need order-1 pages to work ;)

Any kmem_cache using order-1 or order-2 pages can not allocate new slabs

For example, TCP sockets can not be allocated anymore, and fork() might
not work anymore (kernel stacks need order-1 pages)

I dont remember your case, but do you use CONFIG_COMPACTION=y ?
