From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 04 Aug 2006 10:28:52 -0700
Message-ID: <1154712532.3117.43.camel@rh4>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
 <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2>
 <1154650197.3117.32.camel@rh4>
 <20060804011027.GC12085@gondor.apana.org.au>
 <20060804083734.GA16082@gondor.apana.org.au>
 <20060804101017.GA17393@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	"Stephen Hemminger" <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:28679 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1161335AbWHDR1Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 13:27:25 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>, davem@davemloft.net
In-Reply-To: <20060804101017.GA17393@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-04 at 20:10 +1000, Herbert Xu wrote:

> 1) netif_wake_queue is about to occur.  In this case it doesn't really
> matter what we do as netif_wake_queue will always wake the queue for us.
> In the worst case, it'll wake up the queue with too little room but that's
> really uncommon and we can cope with that anyway.
> 
In a lot of other drivers including tg3, waking the tx queue when there
is not enough room in the tx ring is considered a bug and will trigger a
BUG message:

BUG! Tx Ring full when queue awake!

May be David can explain why it is undesirable to wake up the queue when
it is full?

