From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipg: fix an unsigned widening cast of '~' truncation
 issue
Date: Wed, 15 May 2013 14:54:23 -0700 (PDT)
Message-ID: <20130515.145423.1386765446739602879.davem@davemloft.net>
References: <20130515072002.GD20381@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071Ab3EOVyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 17:54:24 -0400
In-Reply-To: <20130515072002.GD20381@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 15 May 2013 10:20:02 +0300

> The bug here is this code from ipg_nic_hard_start_xmit():
> 
> 	txfd->tfc &= cpu_to_le64(~IPG_TFC_TFDDONE);
> 
> IPG_TFC_TFDDONE is 0x0000000080000000 so it's an unsigned int.  The
> negated value is 0x7fffffff but 0xffffffff7fffffff was intended.
> 
> The other values in this file don't need to be changed but I did it for
> consistency.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
