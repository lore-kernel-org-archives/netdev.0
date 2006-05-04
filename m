From: Kelly Daly <kelly@au1.ibm.com>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 4 May 2006 12:59:23 +1000
Message-ID: <200605041259.23204.kelly@au.ibm.com>
References: <200604261147.34221.kelly@au.ibm.com> <200604271331.37073.kelly@au.ibm.com> <20060426.232501.119306252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:42955 "EHLO
	ausmtp04.au.ibm.com") by vger.kernel.org with ESMTP
	id S1750898AbWEDC7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 22:59:42 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.6/8.13.5) with ESMTP id k4439vAV242982
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 13:09:58 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4432nQB245890
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 13:02:49 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11/8.13.3) with ESMTP id k442xSjv006766
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 12:59:29 +1000
In-Reply-To: <20060426.232501.119306252.davem@davemloft.net>
Content-Disposition: inline
To: "Undisclosed.Recipients":;
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 27 April 2006 16:25, you wrote:
> So the idea in your scheme is to give the buffer pools to the NIC
> in a per-channel way via a simple descriptor table?  And the u32's
> are arbitrary keys that index into this descriptor table, right?
>

yeah - it _was_...  Although since having a play with coding it into your 
implementation we've come up with the following:

Using the descriptor table adds excess complexity for kernel buffers, and is 
really only useful for userspace.  So instead of using descriptor tables for 
everything we've come up with a dynamic descriptor table scheme instead where 
they are used only for userspace.

The move to skb-ising the buffers has made it more difficult to keep track of 
buffer lifetimes.  Previously we were leaving the buffers in the ring until 
completely finished with them.  The producer could reuse the buffer once the 
consumer head had moved on.  With the graft to skb we can no longer do this 
unless the packets are processed serially (which is ok for socket channels, 
but not realistic for the default).

We DID write an infrastructure to resolve this issue, although it is more 
complex than the dynamic descriptor scheme for userspace.  And we want to 
keep this simple - right?

Cheers,
K

