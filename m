From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates
Date: Wed, 20 Feb 2008 21:46:51 -0800 (PST)
Message-ID: <20080220.214651.235108740.davem@davemloft.net>
References: <47BCD0DF.1050205@chelsio.com>
	<OF5F5F5698.07AB615F-ON652573F6.00142D8A-652573F6.00147DC9@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752620AbYBUFqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 00:46:14 -0500
In-Reply-To: <OF5F5F5698.07AB615F-ON652573F6.00142D8A-652573F6.00147DC9@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 21 Feb 2008 09:13:49 +0530

> Hi Divy,
> 
> > > Explain why, so I can include it in the changelog please...
> >
> > Hi Jeff,
> >
> > The first part of the patch removes the !netif_queue_stopped(dev).
> > It opens the race discussed a while ago between Stephen hemminger and
> > David Miller:
> > http://marc.info/?l=linux-netdev&m=113383224512427&w=2
> 
> I feel this race cannot happen anymore. I think the fix for that race was
> to introduce the
> __LINK_STATE_QDISC_RUNNING bit thus eliminating any races between CPU's. If
> one
> CPU has called xmit, the other CPU will enqueue skbs (by holding the
> queue_lock) and
> exit from qdisc_run since it finds the bit set already.

And the race is talking about LLTX, which S2IO doesn't use as
far as I can tell.
