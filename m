From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen: netfront: handle incoming GSO SKBs which are not
 CHECKSUM_PARTIAL
Date: Thu, 27 Jan 2011 14:23:48 -0800 (PST)
Message-ID: <20110127.142348.39184559.davem@davemloft.net>
References: <1296042981.14780.6813.camel@zakaz.uk.xensource.com>
	<1296137643-24814-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy@goop.org,
	xen-devel@lists.xensource.com
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753447Ab1A0WXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:23:13 -0500
In-Reply-To: <1296137643-24814-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 27 Jan 2011 14:14:03 +0000

> The Linux network stack expects all GSO SKBs to have ip_summed ==
> CHECKSUM_PARTIAL (which implies that the frame contains a partial
> checksum) and the Xen network ring protocol similarly expects an SKB
> which has GSO set to also have NETRX_csum_blank (which also implies a
> partial checksum).
> 
> However there have been cases of buggy guests which mark a frame as
> GSO but do not set csum_blank. If we detect that we a receiving such a
> frame (which manifests as ip_summed != PARTIAL && skb_is_gso) then
> force the SKB to partial and recalculate the checksum, since we cannot
> rely on the peer having done so if they have not set csum_blank.
> 
> Add an ethtool stat to track occurances of this event.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Looks great, applied, thanks Ian.
