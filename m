From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 12:03:59 -0800
Message-ID: <1387483439.19078.372.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131219193231.GB14612@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46915 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113Ab3LSUEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:04:01 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so1617433pbc.11
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 12:04:00 -0800 (PST)
In-Reply-To: <20131219193231.GB14612@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 20:32 +0100, Richard Cochran wrote:
> On Thu, Dec 19, 2013 at 10:53:02AM -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > skb_tx_timestamp(skb) should be called _before_ TX completion
> > has a chance to trigger, otherwise it is too late and we access
> > freed memory.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Fixes: de5fb0a05348 ("net: fec: put tx to napi poll function to fix dead lock")
> 
> So the hw_lock spin lock was protecting against this issue?
> 
> Nice catch. How ever did you find this?

While looking at another driver, founding the same issue.
