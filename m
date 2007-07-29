From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Sat, 28 Jul 2007 22:30:49 -0700 (PDT)
Message-ID: <20070728.223049.78711264.davem@davemloft.net>
References: <20070723.210748.63127793.davem@davemloft.net>
	<ada6444y2nd.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59826
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752720AbXG2Fau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 01:30:50 -0400
In-Reply-To: <ada6444y2nd.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Sat, 28 Jul 2007 08:21:58 -0700

>  > Another area of consternation are drivers that were using
>  > netif_rx_reschedule(), as that interface was removed because it
>  > doesn't fit well with the caller managing the dev->quota et al.  I
>  > left race conditions in the drivers that were using that interface,
>  > but they should still basically work nonetheless.
> 
> ...but this is a problem for IPoIB.  The underlying IB stuff only
> allows us to register what is essentially a one-shot edge-triggered
> interrupt.  So there is a race between calling netif_rx_complete() and
> calling ib_req_notify_cq() (which enables the interrupt), since the
> interrupt might never happen if a packet arrives between the two calls.

You will see further along in the thread that we have found
a locking sequence by which this issue can be resolved.

Please read the full thread and the most recent patch before
coming to conclusions :-)
