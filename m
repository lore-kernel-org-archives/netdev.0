From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] A few minor clean-ups to eth_type_trans
Date: Sun, 03 May 2015 22:47:59 -0400 (EDT)
Message-ID: <20150503.224759.147226254654842153.davem@davemloft.net>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbbEDCsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 22:48:03 -0400
In-Reply-To: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Thu, 30 Apr 2015 14:53:42 -0700

> This series addresses a few minor issues I found in eth_type_trans that
> that allow us to gain back something like 3 or more cycles per packet.  
> 
> The first change is to drop the byte swap since it isn't necessary.  On x86
> we could just check the first byte and compare that against the upper 8
> bits of the Ethertype to determine if we are dealing with a size value or
> not.
> 
> The second makes it so that the value we read in to test for multicast can
> be used for the address comparison.  This allows us to avoid a second read
> of the destination address.
> 
> The final change is to avoid some unneeded instructions in computing the
> Ethernet header pointer.  When we start the call the Ethernet header is at
> skb->data, so we just use that rather than computing mac_header, and then
> adding that back to skb->head.

Series applied, thanks Alex.
