From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [Bugme-new] [Bug 12087] New: [drivers/net/cxgb3/sge.c:563]: Possible memory leak: s
Date: Sat, 22 Nov 2008 22:03:05 -0800
Message-ID: <adaiqqff086.fsf@cisco.com>
References: <bug-12087-10286@http.bugzilla.kernel.org/>
	<20081122213532.fe01a22c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	danielm77@spray.se, Jay Cliburn <jacliburn@bellsouth.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:26589 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbYKWGDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 01:03:09 -0500
In-Reply-To: <20081122213532.fe01a22c.akpm@linux-foundation.org> (Andrew
	Morton's message of "Sat, 22 Nov 2008 21:35:32 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There will be a memory leak in the function alloc_ring when the parameter
> sw_size is nonzero and metadata is NULL. I don't know if that can happen.
> 
> Here is the code, taken from the latest git tree.
> 
> static void *alloc_ring(struct pci_dev *pdev, size_t nelem, size_t elem_size,
>                         size_t sw_size, dma_addr_t * phys, void *metadata)

It might make sense to stick a WARN_ON(sw_size && !metadata) in that
function or something like that, but a quick audit of the current code
(there are only 4 callers of alloc_ring() in that file -- and it's
static so we know those are all of them -- all in t3_sge_alloc_qset())
shows that all callers pass non-NULL metadata if sw_size != 0.

 - R.
