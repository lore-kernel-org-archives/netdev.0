From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] xen/netback: correctly calculate required slots
 of skb.
Date: Thu, 11 Jul 2013 13:03:14 -0700 (PDT)
Message-ID: <20130711.130314.2300492549661006309.davem@davemloft.net>
References: <1373447711-31303-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	Ian.Campbell@citrix.com, wei.liu2@citrix.com,
	konrad.wilk@oracle.com, msw@amazon.com
To: annie.li@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab3GKUDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 16:03:15 -0400
In-Reply-To: <1373447711-31303-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Annie Li <annie.li@oracle.com>
Date: Wed, 10 Jul 2013 17:15:11 +0800

> When counting required slots for skb, netback directly uses DIV_ROUND_UP to get
> slots required by header data. This is wrong when offset in the page of header
> data is not zero, and is also inconsistent with following calculation for
> required slot in netbk_gop_skb.
> 
> In netbk_gop_skb, required slots are calculated based on offset and len in page
> of header data. It is possible that required slots here is larger than the one
> calculated in earlier netbk_count_requests. This inconsistency directly results
> in rx_req_cons_peek and xen_netbk_rx_ring_full judgement are wrong.
> 
> Then it comes to situation the ring is actually full, but netback thinks it is
> not and continues to create responses. This results in response overlaps request
> in the ring, then grantcopy gets wrong grant reference and throws out error,
> for example "(XEN) grant_table.c:1763:d0 Bad grant reference 2949120", the
> grant reference is invalid value here. Netback returns XEN_NETIF_RSP_ERROR(-1)
> to netfront when grant copy status is error, then netfront gets rx->status
> (the status is -1, not really data size now), and throws out error,
> "kernel: net eth1: rx->offset: 0, size: 4294967295". This issue can be reproduced
> by doing gzip/gunzip in nfs share with mtu = 9000, the guest would panic after
> running such test for a while.
> 
> This patch is based on 3.10-rc7.
> 
> Signed-off-by: Annie Li <annie.li@oracle.com>

A lot of discussion... will we have another respin of this patch or can I
get an ACK from Ian or someone else?

Thanks.
