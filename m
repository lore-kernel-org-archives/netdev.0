From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with
 software LRO
Date: Fri, 27 Jun 2008 17:27:36 -0700 (PDT)
Message-ID: <20080627.172736.147638545.davem@davemloft.net>
References: <200806181907.16584.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52660
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753136AbYF1A1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 20:27:36 -0400
In-Reply-To: <200806181907.16584.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed, 18 Jun 2008 19:07:16 +0300

>     tcp: fix for splice receive when used with software LRO
>     
>     If an skb has nr_frags set to zero but its frag_list is not empty (as
>     it can happen if software LRO is enabled), and a previous
>     tcp_read_sock has consumed the linear part of the skb, then
>     __skb_splice_bits:
>     
>     (a) incorrectly reports an error and
>     
>     (b) forgets to update the offset to account for the linear part
>     
>     Any of the two problems will cause the subsequent __skb_splice_bits
>     call (the one that handles the frag_list skbs) to either skip data,
>     or, if the unadjusted offset is greater then the size of the next skb
>     in the frag_list, make tcp_splice_read loop forever.
>     
>     Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Applied, th anks Octavian.
