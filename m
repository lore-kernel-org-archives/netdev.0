From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [Cbe-oss-dev] [PATCH 4/10] spidernet: zero out a pointer.
Date: Tue, 22 May 2007 18:35:18 -0500
Message-ID: <20070522233517.GU5921@austin.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com> <20070516220928.GD4997@austin.ibm.com> <1179358376.4142.4.camel@concordia.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:35311 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757285AbXEVXfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 19:35:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MMXFXT015143
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 18:33:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNZJhl540866
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:35:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNZINX004787
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:35:18 -0400
Content-Disposition: inline
In-Reply-To: <1179358376.4142.4.camel@concordia.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 17, 2007 at 09:32:56AM +1000, Michael Ellerman wrote:
> > +	hwdescr->buf_addr = 0x0;
> 
> If you're going to be paranoid, shouldn't you do something here to make
> sure the value's hit the device?

I thought the whole point of paranoia is that its inexplicable.

Here's a delusional reply: I didn't see any point to it. 
1) a wmb would add overhead
2) the hardware is supposed to be looking at the status flag,
   anyway, and not misbehaving.
3) there is a wmb when the descr is actually refilled in such
   a way as to actually mean something to the hardware.

All that I really acomplished here is a minor trick to 
aid in debug printing when looking for something bad.

--linas

