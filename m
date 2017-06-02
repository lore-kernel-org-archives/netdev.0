From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davicom: dm9000: Avoid spinlock recursion during
 dm9000_timeout routine
Date: Fri, 02 Jun 2017 14:12:45 -0400 (EDT)
Message-ID: <20170602.141245.815479944666453393.davem@davemloft.net>
References: <1496243202-3492-1-git-send-email-liu.xiang6@zte.com.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: liu.xiang6@zte.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBSMr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:12:47 -0400
In-Reply-To: <1496243202-3492-1-git-send-email-liu.xiang6@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liu Xiang <liu.xiang6@zte.com.cn>
Date: Wed, 31 May 2017 23:06:42 +0800

> On the DM9000B, dm9000_phy_write() is called after the main spinlock
> is held, during the dm9000_timeout() routine. Spinlock recursion
> occurs because the main spinlock is requested again in
> dm9000_phy_write(). So spinlock should be avoided in dm9000_phy_write()
> during the dm9000_timeout() routine.
> 
> Signed-off-by: Liu Xiang <liu.xiang6@zte.com.cn>

It think this is racy.

Now, during a timeout device reset, another thread of control can come
in and access phy registers without any synchronization whatsoever.
