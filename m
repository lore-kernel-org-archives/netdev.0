From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 10/10] amd-xgbe: Rework the Rx path SKB
 allocation
Date: Thu, 19 Mar 2015 16:20:00 -0400 (EDT)
Message-ID: <20150319.162000.938727994480466006.davem@davemloft.net>
References: <20150319200808.28321.37307.stgit@tlendack-t1.amdoffice.net>
	<20150319200908.28321.60118.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbCSUUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 16:20:03 -0400
In-Reply-To: <20150319200908.28321.60118.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 19 Mar 2015 15:09:08 -0500

> When the driver creates an SKB it currently only copies the header
> buffer data (which can be just the header if split header processing
> succeeded or header plus data if split header processing did not
> succeed) into the SKB. The receive buffer data is always added as a
> frag, even if it could fit in the SKB. As part of SKB creation, inline
> the receive buffer data if it will fit in the the SKB, otherwise add it
> as a frag during SKB creation.
> 
> Also, Update the code to trigger off of the first/last descriptor
> indicators and remove the incomplete indicator.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

I do not understand the motivation for this, could you explain?

The less copying you do the better, just having the headers in the
linear area is the most optimal situation, and have all the data
in page frag references.
