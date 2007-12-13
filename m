From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [kvm-devel] [PATCH resent] virtio_net: Fix stalled inbound trafficon early packets
Date: Thu, 13 Dec 2007 19:30:31 +0100
Message-ID: <200712131930.31602.borntraeger@de.ibm.com>
References: <200712111242.28843.borntraeger@de.ibm.com> <200712121914.38135.borntraeger@de.ibm.com> <47613277.3060403@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel <kvm-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: dor.laor@qumranet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:10252 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763588AbXLMSai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 13:30:38 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBDIUa1r016816
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 18:30:36 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDIUa1e2801670
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 19:30:36 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDIUZDt021214
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 19:30:36 +0100
In-Reply-To: <47613277.3060403@qumranet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 13. Dezember 2007 schrieb Dor Laor:
> You're right I got confused somehow.
> So in that case setting the driver status field on open in addition to 
> your enable will do the trick.
> On DRIVER_OPEN the host will trigger an interrupt if the queue is not 
> empty..
> Thanks,
> Dor

After looking into some other drivers, I prefer my first patch (moving 
napi_enable) ;-)

There are some drivers like xen-netfront, b44, which call napi_enable before 
the buffers are passed to the hardware. So it seems that moving napi is 
also a valid option.

But maybe I can just wait until Rusty returns from vacation (I will leave 
next week) so everything might be wonderful when I return ;-)

Rusty, if you decide to apply my patch, there is one downside: The debugging 
code in virtio_ring sometimes triggers with a false positive:

try_fill_recv calls vring_kick. Here we do a notify to the host. This might 
cause an immediate interrupt, triggering the poll routine before vring_kick 
can run END_USE. This is no real problem, as we dont touch the vq after 
notify.

Christian, facing 64 guest cpus unconvering all kind of races

