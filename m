From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [git patches] net driver updates
Date: Thu, 21 Feb 2008 09:13:49 +0530
Message-ID: <OF5F5F5698.07AB615F-ON652573F6.00142D8A-652573F6.00147DC9@in.ibm.com>
References: <47BCD0DF.1050205@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:36471 "EHLO
	e28esmtp03.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753718AbYBUDpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 22:45:46 -0500
In-Reply-To: <47BCD0DF.1050205@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Divy,

> > Explain why, so I can include it in the changelog please...
>
> Hi Jeff,
>
> The first part of the patch removes the !netif_queue_stopped(dev).
> It opens the race discussed a while ago between Stephen hemminger and
> David Miller:
> http://marc.info/?l=linux-netdev&m=113383224512427&w=2

I feel this race cannot happen anymore. I think the fix for that race was
to introduce the
__LINK_STATE_QDISC_RUNNING bit thus eliminating any races between CPU's. If
one
CPU has called xmit, the other CPU will enqueue skbs (by holding the
queue_lock) and
exit from qdisc_run since it finds the bit set already.

Thanks,

- KK

