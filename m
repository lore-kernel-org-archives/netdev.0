From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Avoid extra calculation in ip_route_input_common
Date: Wed, 21 Dec 2011 00:57:58 -0500 (EST)
Message-ID: <20111221.005758.556186611596801704.davem@davemloft.net>
References: <4EF16AA3.2070303@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangyun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab1LUF6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 00:58:04 -0500
In-Reply-To: <4EF16AA3.2070303@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Wang <wangyun@linux.vnet.ibm.com>
Date: Wed, 21 Dec 2011 13:12:03 +0800

> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> If previous condition doesn't meet, the later check will be cancelled.
> So we don't need to do all the calculation.
> 
> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>

This is intentional to reduce the number of branch prediction
misses, please don't change this.

Once we read one of these values, the rest are incredibly cheap,
the real cost is if we have tons of real branches here, each
of which can be mispredicted.
