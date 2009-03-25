From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/6] s390: qeth fixes for 2.6.30
Date: Wed, 25 Mar 2009 16:47:04 -0700 (PDT)
Message-ID: <20090325.164704.89679614.davem@davemloft.net>
References: <20090325065713.054133000@de.ibm.com>
	<20090325.000817.183932373.davem@davemloft.net>
	<49C9EA6A.90808@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbZCYXrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 19:47:17 -0400
In-Reply-To: <49C9EA6A.90808@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Wed, 25 Mar 2009 09:25:14 +0100

> > Your EDDP was slow because the implementation was incredibly
> > sub-optimal.  %90 of the code is doing copies and fiddling
> > with SKB internals.
> 
> I did not wrote the EDDP code but this was my impression too. Thanks for
> confirming my study. Also the filling of the hardware buffers was not
> efficient and passing more buffers to the hw was expensive too.

I keep meaning to get back to a project I was working on that
would make generic the by-hand TSO that drivers such as
drivers/net/sfc/ are doing.

Just like this EDDP code seems to have been doing, they claim
to be TSO capable as a device but it is all done in software.

The hope is to write a generic framework, and skb_dma_map() and
skb_dma_unmap() were created as initial infrastructure for that.

Anyways, if I ever complete that project, drivers like qeth
could try to make use of it and do some perf tests.
