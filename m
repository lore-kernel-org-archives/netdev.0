From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: RE: [git patches] net driver updates
Date: Thu, 21 Feb 2008 11:32:08 +0530
Message-ID: <OF476723A4.55F404FB-ON652573F6.0021051A-652573F6.002127B3@in.ibm.com>
References: <8A71B368A89016469F72CD08050AD334026D6511@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David Miller" <davem@davemloft.net>, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Divy Le Ray" <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:56137 "EHLO
	e28esmtp07.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751595AbYBUGDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 01:03:25 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD334026D6511@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Divy,

But the race doesn't exist even for LLTX drivers these days. There is no
way two cpu's can execute the xmit handler at the same time.

Thanks,

- KK

> > > > The first part of the patch removes the !netif_queue_stopped(dev).
> > > > It opens the race discussed a while ago between Stephen hemminger
> > and
> > > > David Miller:
> > > > http://marc.info/?l=linux-netdev&m=113383224512427&w=2
> > >
> > > I feel this race cannot happen anymore. I think the fix for that
> race
> > was
> > > to introduce the
> > > __LINK_STATE_QDISC_RUNNING bit thus eliminating any races between
> > CPU's. If
> > > one
> > > CPU has called xmit, the other CPU will enqueue skbs (by holding the
> > > queue_lock) and
> > > exit from qdisc_run since it finds the bit set already.
> >
> > And the race is talking about LLTX, which S2IO doesn't use as
> > far as I can tell.
>
> Dave,
>
> The driver is cxgb3 here, it uses LLTX.
>
> Cheers,
> Divy

