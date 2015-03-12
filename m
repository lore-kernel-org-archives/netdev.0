From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rds: avoid potential stack overflow
Date: Thu, 12 Mar 2015 00:28:18 -0400 (EDT)
Message-ID: <20150312.002818.1582458495369122296.davem@davemloft.net>
References: <4321699.nNdBmxDHpu@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com,
	rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, sowmini.varadhan@oracle.com,
	linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbbCLE2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 00:28:20 -0400
In-Reply-To: <4321699.nNdBmxDHpu@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Mar 2015 22:46:59 +0100

> The rds_iw_update_cm_id function stores a large 'struct rds_sock' object
> on the stack in order to pass a pair of addresses. This happens to just
> fit withint the 1024 byte stack size warning limit on x86, but just
> exceed that limit on ARM, which gives us this warning:
> 
> net/rds/iw_rdma.c:200:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
> As the use of this large variable is basically bogus, we can rearrange
> the code to not do that. Instead of passing an rds socket into
> rds_iw_get_device, we now just pass the two addresses that we have
> available in rds_iw_update_cm_id, and we change rds_iw_get_mr accordingly,
> to create two address structures on the stack there.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> v2: fix incorrect commit message

Applied, thanks Arnd.
