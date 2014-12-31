From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 23/23 V2 for 3.19]  rtlwifi: Fix error when accessing
 unmapped memory in skb
Date: Tue, 30 Dec 2014 18:49:47 -0600
Message-ID: <20141231004947.GA2007@zzz>
References: <1419711457-21469-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:50450 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaLaAtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 19:49:51 -0500
Content-Disposition: inline
In-Reply-To: <1419711457-21469-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 27, 2014 at 02:17:37PM -0600, Larry Finger wrote:
> These drivers use 9100-byte receive buffers, thus allocating an skb requires
> an O(3) memory allocation. Under heavy memory loads and fragmentation, such
> a request can fail. Previous versions of the driver have dropped the packet
> and reused the old buffer; however, the new version introduced a bug in that
> it released the old buffer before trying to allocate a new one. The previous
> method is implemented here.

It looks like in the out-of-memory path, pci_map_single() gets called while the
skb is still mapped.  Won't this leak the IOMMU mapping?
