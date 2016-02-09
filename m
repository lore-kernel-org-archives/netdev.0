From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Tue, 09 Feb 2016 07:08:43 -0500 (EST)
Message-ID: <20160209.070843.147439680193879267.davem@davemloft.net>
References: <20160209104929.14628.52355.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	tom@herbertland.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409AbcBIMIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 07:08:51 -0500
In-Reply-To: <20160209104929.14628.52355.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 09 Feb 2016 02:49:54 -0800

> This patch fixes an issue with unaligned accesses when using
> eth_get_headlen on a page that was DMA aligned instead of being IP aligned.
> The fact is when trying to check the length we don't need to be looking at
> the flow label so we can reorder the checks to first check if we are
> supposed to gather the flow label and then make the call to actually get
> it.
> 
> v2:  Updated path so that either STOP_AT_FLOW_LABEL or KEY_FLOW_LABEL can
>      cause us to check for the flow label.
> 
> Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied and queued up for -stable, thanks Alex.
