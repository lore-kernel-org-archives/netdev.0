From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: check dst validity after IPsec operations
Date: Thu, 06 Sep 2012 14:10:19 -0400 (EDT)
Message-ID: <20120906.141019.129727465932440024.davem@davemloft.net>
References: <1346953229-3825-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, sri@us.ibm.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787Ab2IFSKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 14:10:21 -0400
In-Reply-To: <1346953229-3825-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  6 Sep 2012 13:40:29 -0400

> dst stored in struct sctp_transport needs to be recalculated when ipsec policy
> are updated. We use flow_cache_genid for that.
> 
> For example, if a SCTP connection is established and then an IPsec policy is
> set, the old SCTP flow will not be updated and thus will not use the new
> IPsec policy.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I don't like that SCTP need to perform special DST validation.

The normal DST validation mechanism already in place should be
sufficient.

Otherwise this problem must exist in other protocols too, and
fixing a tree wide issue privately inside of one protocol is
not acceptable.
