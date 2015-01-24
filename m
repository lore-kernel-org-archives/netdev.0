From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] xen-netback: always fully coalesce guest Rx
 packets
Date: Fri, 23 Jan 2015 17:57:18 -0800 (PST)
Message-ID: <20150123.175718.1746060859200808793.davem@davemloft.net>
References: <1421765392-30303-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbbAXB5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 20:57:20 -0500
In-Reply-To: <1421765392-30303-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 20 Jan 2015 14:49:52 +0000

> Always fully coalesce guest Rx packets into the minimum number of ring
> slots.  Reducing the number of slots per packet has significant
> performance benefits when receiving off-host traffic.
> 
> Results from XenServer's performance benchmarks:
> 
>                          Baseline    Full coalesce
> Interhost VM receive      7.2 Gb/s   11 Gb/s
> Interhost aggregate      24 Gb/s     24 Gb/s
> Intrahost single stream  14 Gb/s     14 Gb/s
> Intrahost aggregate      34 Gb/s     34 Gb/s
> 
> However, this can increase the number of grant ops per packet which
> decreases performance of backend (dom0) to VM traffic (by ~10%)
> /unless/ grant copy has been optimized for adjacent ops with the same
> source or destination (see "grant-table: defer releasing pages
> acquired in a grant copy"[1] expected in Xen 4.6).
> 
> [1] http://lists.xen.org/archives/html/xen-devel/2015-01/msg01118.html
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> ---
> Changes in v2:
> - Updated commit message with better results.

Applied, thanks David.
