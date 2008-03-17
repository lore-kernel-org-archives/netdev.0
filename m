From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] virtio_net/virtio_ring: fix race in enable_cb
Date: Mon, 17 Mar 2008 07:30:44 +0100
Message-ID: <200803170730.44218.borntraeger@de.ibm.com>
References: <200803141417.05696.borntraeger@de.ibm.com> <200803171248.14570.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:63975 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbYCQGar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 02:30:47 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m2H6UkGq130708
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 06:30:46 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2H6UkSF1777690
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 06:30:46 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2H6UjMU026465
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 06:30:45 GMT
In-Reply-To: <200803171248.14570.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Are you seeing the "Unlikely: restart svq failed" message in the logs?  If 
> not, I don't think it can be this race.

No, I dont see the message, but this message only happens for guest->host 
traffic in the xmit function. I was fixing the poll function - which has no 
printk.
I added the disable_cb in the xmit function only  to adopt to changed 
enable_cb semantics.

I double checked my theory with a printk in enable_cb. The more_used check 
was true several times for the receiving virtqueue. 

Christian
