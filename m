From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Fri, 8 Jun 2007 11:02:54 +0530
Message-ID: <OFCFDBAE89.6D3D1B4D-ON652572F4.001DC5F4-652572F4.001E7A65@in.ibm.com>
References: <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: auke-jan.h.kok@intel.com, David Miller <davem@davemloft.net>,
	hadi@cyberus.ca, jeff@garzik.org, jesse.brandeburg@intel.com,
	kaber@trash.net, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:35335 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528AbXFHFfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 01:35:20 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l585teYj238182
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:55:51 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l585bZe3189184
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:37:38 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l585XJbw009008
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:33:20 +1000
In-Reply-To: <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If the QDISC_RUNNING flag guarantees that only one CPU can call
> dev->hard_start_xmit(), then why do we need to hold netif_tx_lock
> for non-LLTX drivers?

I thought the correct use is to get this lock on clean_tx side which
can get called on a different cpu on rx (which also cleans up slots
for skbs that have finished xmit). Both TX and clean_tx uses the
same tx_ring's head/tail ptrs and should be exclusive. But I don't
find clean tx using this lock in the code, so I am confused :-)

- KK

