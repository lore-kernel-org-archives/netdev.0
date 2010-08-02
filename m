From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: check for reference outside of skb
Date: Mon, 02 Aug 2010 15:59:37 -0700 (PDT)
Message-ID: <20100802.155937.58423604.davem@davemloft.net>
References: <20100802220030.991706005@vyatta.com>
	<20100802220113.557212477@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754298Ab0HBW7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 18:59:19 -0400
In-Reply-To: <20100802220113.557212477@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 02 Aug 2010 15:00:31 -0700

> It is legitimate for callers of skb_header_pointer to pass a negative
> offset, but the resulting pointer should not go outside the valid
> range of data in the skb.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Stephen, it seems to me that most existing (if not all) callers of
skb_header_pointer() already can prove that their offsets are
legitimate, negative or not.  They usually do this via pskb_may_pull()
or similar.

Therefore it makes no sense to me that we punish all existing code paths
with a duplicate test just to have this check available for use in u32.

Just put the range test in u32.

Thanks.

