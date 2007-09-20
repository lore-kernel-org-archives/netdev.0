From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [Bug, PATCH and another Bug] Was: Fix refcounting problem with netif_rx_reschedule()
Date: Thu, 20 Sep 2007 10:48:15 +0530
Message-ID: <OF8B3BDDEC.3F73CFD4-ON6525735C.001C8A0F-6525735C.001D2340@in.ibm.com>
References: <20070919.090557.24612742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	rdreier@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP03.au.ibm.com ([202.81.18.172]:35952 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbXITFQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 01:16:16 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8K5GEUV012343
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 15:16:14 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8K5GEjE3870758
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 15:16:14 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8K5GDHA024955
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 15:16:14 +1000
In-Reply-To: <20070919.090557.24612742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller <davem@davemloft.net> wrote on 09/19/2007 09:35:57 PM:

> The NAPI_STATE_SCHED flag bit should provide all of the necessary
> synchornization.
>
> Only the setter of that bit should add the NAPI instance to the
> polling list.
>
> The polling loop runs atomically on the cpu where the NAPI instance
> got added to the per-cpu polling list.  And therefore decisions to
> complete NAPI are serialized too.
>
> That serialized completion decision is also when the list deletion
> occurs.

About the "list deletion occurs", isn't the race I mentioned still present?
If done < budget, the driver does netif_rx_complete (at which time some
other
cpu can add this NAPI to their list). But the first cpu might do some more
actions on the napi, like ipoib_poll() calls request_notify_cq(priv->cq),
when other cpu might have started using this napi.

(net_rx_action's 'list_move' however will not execute since work != weight)

Thanks,

- KK

