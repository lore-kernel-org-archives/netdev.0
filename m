From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods (v3)
Date: Wed, 17 Aug 2011 16:07:17 +0100
Message-ID: <1313593637.2776.9.camel@bwh-desktop>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	 <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8678 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520Ab1HQPHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 11:07:21 -0400
In-Reply-To: <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-26 at 12:05 -0400, Neil Horman wrote:
> Ok, after considering all your comments, Dave suggested this as an alternate
> approach:
> 
> 1) We create a new priv_flag, IFF_SKB_TX_SHARED, to identify drivers capable of
> handling shared skbs.  Default is to not set this flag
> 
> 2) Modify ether_setup to enable this flag, under the assumption that any driver
> calling this  function is initalizing a real ethernet device and as such can
> handle shared skbs since they don't tend to store state in the skb struct.
> Pktgen can then query this flag when a user script attempts to issue the
> clone_skb command and decide if it is to be alowed or not.
[...]

A bunch of Ethernet drivers do skb_pad() or skb_padto() in their
ndo_start_xmit implementations, either to avoid hardware bugs or because
the MAC doesn't automatically pad to the minimum frame length.  This
presumably means they can't generally handle shared skbs, though in the
specific case of pktgen it should be safe as long as a single skb is not
submitted by multiple threads at once.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

