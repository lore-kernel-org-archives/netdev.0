From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [kvm-devel] [PATCH resent] virtio_net: Fix stalled inbound trafficon early packets
Date: Wed, 12 Dec 2007 12:27:01 +0100
Message-ID: <200712121227.01828.borntraeger@de.ibm.com>
References: <200712111242.28843.borntraeger@de.ibm.com> <200712111627.21364.borntraeger@de.ibm.com> <475F1E86.8000503@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel <kvm-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: dor.laor@qumranet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:47988 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbXLLL1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 06:27:25 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBCBRO2m193534
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 11:27:24 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBCBRNEk4804736
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 11:27:23 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBCBRHMW023401
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 11:27:17 GMT
In-Reply-To: <475F1E86.8000503@qumranet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 12. Dezember 2007 schrieb Dor Laor:
> This is why initially I suggested another status code in order to split 
> the ring logic with driver status.
> > but also not filling any buffers as long as VIRTIO_CONFIG_DEV_OPEN is 
not 
> > set. I will have a look but I think that add_status needs to be called 
> >   
> It can fill the buffers even without dev_open, when the dev is finally 
> opened the host will issue an interrupt if there are pending buffers. 

There is a problem associated with that scheme. Setting the value in the 
config space does not notify the hypervisor. That means the host will not 
send an interrupt. The interrupt is sent if the host tries to send the next 
packet. If somehow the host manages to use up all buffers before the device 
is finally opened, we have a problem.
> (I'm not sure it's worth solving, maybe  just drop them like you 
suggested).
As said above, dropping seems to me the preferred method. Did I miss 
something?

Christian
