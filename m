From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/3] A few minor clean-ups to eth_type_trans
Date: Thu, 30 Apr 2015 15:35:13 -0700
Message-ID: <20150430223510.GA13111@Alexeis-MBP.westell.com>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37370 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbbD3WfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:35:17 -0400
Received: by igblo3 with SMTP id lo3so26251596igb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:35:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 02:53:42PM -0700, Alexander Duyck wrote:
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

Great stuff! Excellent optimizations.

Only the comment 'ETH_P_802_3_MIN is aligned to 512' through me off.
It's divisible by 256 that matters.
