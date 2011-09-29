From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Re: [PATCH] RDSRDMA: Fix cleanup of rds_iw_mr_pool
Date: Thu, 29 Sep 2011 11:51:47 -0700 (PDT)
Message-ID: <c8acdbc4-7b18-4232-a636-e83dfbf310e4@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: <jonathan@ogc.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:37496 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681Ab1I2Sv7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 14:51:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the rds_iw_mr_pool struct the free_pinned field keeps track of
memory pinned by free MRs. While this field is incremented properly
upon allocation, it is never decremented upon unmapping. This would
cause the rds_rdma module to crash the kernel upon unloading, by
triggering the BUG_ON in the rds_iw_destroy_mr_pool function.

This change keeps track of the MRs that become unpinned, so that
free_pinned can be decremented appropriately.

Signed-off-by: Jonathan Lallinger <jonathan@ogc.us>
Signed-off-by: Steve Wise <swise@ogc.us>
---

Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>

Venkat
