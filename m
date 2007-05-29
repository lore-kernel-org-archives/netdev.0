From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Definition and usage of NETIF_F_HW_SUM?
Date: Tue, 29 May 2007 13:58:13 -0700
Message-ID: <20070529135813.63303693@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:41713 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759646AbXE2VHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 17:07:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The flag NETIF_F_HW_SUM is being misused. The definition says that the device
is capable of checksumming any packet. When in fact from usage it seems to
imply that the device is capable of doing IPV6 as well as IPV4.

Some devices like 8139too do "fake checksum offloading" because they always have to copy
the packet.

Some devices like via-rhine, don't really checksum but if they see CHECKSUM_PARTIAL then they
copy. This is bogus, they should just let higher layer do checksum/copy.

Devices like e1000, and bnx2 are broken because they assume only TCP/UDP and IPV4/IPV6. 
The definition of the flag says other protocols should work, but they probably send the
hardware into a state of confusion.

A few devices take a offset, starting point, and insertion point. This looks like
the correct model. But no upper layer protocols other than IPV4/IPV6 can do checksum
offload at present, so it seems moot.

IMHO the correct solution would be to get rid if NETIF_F_HW_SUM and make a new flag
NETIF_F_IPV6_SUM. Devices that can checksum both could do NETIF_F_IPV4_SUM|NETI_F_IPV6_SUM.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
