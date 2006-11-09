From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3_close question
Date: Thu, 9 Nov 2006 08:53:43 -0800
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FCCF@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <1551EAE59135BE47B544934E30FC4FC093FCCE@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:63247 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1424118AbWKIQx5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 11:53:57 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FCCE@NT-IRVA-0751.brcm.ad.broadcom.com>
To: "Eric Lemoine" <eric.lemoine@gmail.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:

> Eric Lemoine wrote:
> 
> > Instead of tg3_netif_stop() tg3_close() uses netif_stop_queue()
> > to stop xmit. This doesn't seem right to me. E.g. another CPU 
> > in tg3_tx()
> > could do netif_wake_queue() just after tg3_close() did
> > netif_stop_queue(). Isn't a bug?
> > 
> 
> I think you're right.  It is more correct to call tg3_netif_stop().
> 

I take it back.  Before ->stop() is called, netif_running is cleared,
and it waits for __LINK_STATE_RX_SCHED to be cleared.  This means
that it will wait for the last ->poll() to finish.

So it is not possible for tg3_poll() -> tg3_tx() to run any more
after tg3_close() is called.

