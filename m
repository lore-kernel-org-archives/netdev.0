From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix static checker warnings
Date: Wed, 16 Jul 2014 15:45:42 -0700 (PDT)
Message-ID: <20140716.154542.601722446325914197.davem@davemloft.net>
References: <1405451843-3081-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, hariprasad@chelsio.com,
	dan.carpenter@oracle.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743AbaGPWpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 18:45:44 -0400
In-Reply-To: <1405451843-3081-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 15 Jul 2014 12:17:23 -0700

> This patch fixes static checker warnings as pointed out on by Dan Carpenter
> 
> Fixes: 76bcb31efc06 ("cxgb4 : Add DCBx support codebase  and dcbnl_ops")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

The real bug here is more likely, as Casey Leedom said, that the method
returns u8 instead of int.

The only other implementation of this method, bnx2x, also tries to return
negative error codes.

So please just change the return type in the method signature and the
two implementations.

Thanks.
