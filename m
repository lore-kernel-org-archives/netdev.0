From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] qlcnic: Replace kzalloc() with vzalloc().
Date: Sat, 02 Nov 2013 01:14:59 -0400 (EDT)
Message-ID: <20131102.011459.236177037024354702.davem@davemloft.net>
References: <cover.1383358893.git.himanshu.madhani@qlogic.com>
	<4e485cb2ec05e3cae68fbf59a0f1597a95098a76.1383358893.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	manish.chopra@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab3KBFPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 01:15:06 -0400
In-Reply-To: <4e485cb2ec05e3cae68fbf59a0f1597a95098a76.1383358893.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Fri, 1 Nov 2013 16:51:25 -0400

> From: Manish Chopra <manish.chopra@qlogic.com>
> 
> o Some of the places kzalloc() is not required. Replace it
>   with vzalloc() wherever it is not used appropriately
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

This commit message is terrible.

In what way is kzalloc() inappropriate for these allocations?

Many of them are quite small, and vzalloc() is completely inappropriate
to use in such cases.

You should only use vzalloc() for HUGE allocations, those which
kzalloc() is unable to satisfy.  Many cases changed here in this
patch do not meet that criteria.

I'm tossing this entire patch series.
