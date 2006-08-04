From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 03 Aug 2006 17:09:57 -0700
Message-ID: <1154650197.3117.32.camel@rh4>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
 <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:10767 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932293AbWHDAIa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 20:08:30 -0400
To: hadi@cyberus.ca
In-Reply-To: <1154642918.5187.13.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-03 at 18:08 -0400, jamal wrote:

> 
> Yes in your case you need to hold the lock but not in the e1000 case.
> I dont understand though why you need to check for wake in the tx path.
> 

tg3_start_xmit()

	if (tx_ring_empty)
				<-  tg3_tx()
		netif_stop_queue()


At the arrow, tg3_tx() can come in and clean up the entire ring but will
not see that the queue is stopped and therefore will not call
netif_wake_queue().  As a result, the tx_queue is stopped forever.

