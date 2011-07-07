From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ATM: Fix wrong usage of INIT_WORK
Date: Thu, 07 Jul 2011 04:51:59 -0700 (PDT)
Message-ID: <20110707.045159.735589070219101177.davem@davemloft.net>
References: <1310039512-17579-1-git-send-email-wangshaoyan.pt@taobao.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangshaoyan.pt@taobao.com,
	chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net
To: stufever@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696Ab1GGLyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 07:54:12 -0400
In-Reply-To: <1310039512-17579-1-git-send-email-wangshaoyan.pt@taobao.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stufever@gmail.com
Date: Thu,  7 Jul 2011 19:51:52 +0800

> From: Wang Shaoyan <wangshaoyan.pt@taobao.com>
> 
> If we define FILL_RX_POOLS_IN_BH, the compiler will report error such as
>   drivers/atm/ambassador.c:2159:64: error: macro "INIT_WORK" passed 3 arguments, but takes just 2
> because the function INIT_WORK() don't accept "data" now, it only has
> two arguments, so use the right way to initialise work queue.
> 
> Cc: Chas Williams <chas@cmf.nrl.navy.mil> (maintainer:ATM)
> Cc: linux-atm-general@lists.sourceforge.net (open list:ATM)
> Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>

This just makes the driver a bigger CPP mess.

Unconditionally provide the dev->bh member, and unconditionally pass
it into the worker function.

