From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 1/2] IPoIB: Fix unregister_netdev hang
Date: Wed, 19 Sep 2007 08:53:55 +0530
Message-ID: <OF402F2662.AACCDAF2-ON6525735B.00108C17-6525735B.0012AB74@in.ibm.com>
References: <adalkb4kq0j.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP02.au.ibm.com ([202.81.18.163]:39958 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbXISDXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 23:23:41 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8J3Nas8020774
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 13:23:36 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8J3PsVf273814
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 13:25:54 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8J3KnEI015052
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 13:20:50 +1000
In-Reply-To: <adalkb4kq0j.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Roland,

Roland Dreier <rdreier@cisco.com> wrote on 09/18/2007 07:57:24 PM:

>  > While using IPoIB over EHCA (rc6 bits), unregister_netdev hangs with
>
> I don't think you're actually using rc6 bits, since in your patch you
have:
>
>  > -poll_more:
>
> and I think that is only in Dave's net-2.6.24 tree now, right?

Nope, that was what I downloaded yesterday:

VERSION = 2
PATCHLEVEL = 6
SUBLEVEL = 23
EXTRAVERSION =-rc6
NAME = Pink Farting Weasel

> > +                    if (likely(!ib_req_notify_cq(priv->cq,
> > +
IB_CQ_NEXT_COMP |
> > +
IB_CQ_REPORT_MISSED_EVENTS)))
>
> It is possible for an interrupt to happen immediately right here,
> before the netif_rx_complete(), so that netif_rx_schedule() gets
> called while we are still on the poll list.
>
> > +                                netif_rx_complete(dev, napi);

To be clear, netif_rx_schedule while we are still in the poll list will not
do any harm as it does nothing since NAPI_STATE_SCHED is still set (cleared
by netif_rx_complete which has not yet run). Effectively we lost/delayed
processing an interrupt, if I understood the code right.

I agree with you on the new patch.

thanks,

- KK

