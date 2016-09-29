From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] net/ncsi: Avoid unused-value build
 warning from ia64-linux-gcc
Date: Thu, 29 Sep 2016 01:54:04 -0400 (EDT)
Message-ID: <20160929.015404.76401694814645494.davem@davemloft.net>
References: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
        <1475125395-8459-2-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752887AbcI2FyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 01:54:08 -0400
In-Reply-To: <1475125395-8459-2-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Thu, 29 Sep 2016 15:03:08 +1000

> This replaces the atomic access to NCSI channel's state with READ_ONCE()
> and WRITE_ONCE() to avoid the above build warning. We needn't hold the
> channel's lock when updating its state as well. No logical changes
> introduced.

I don't understand this.

If it's important to take the lock for the list add/del, then it must
be important to make the state change appear atomic wrt. that lock as
well.

Can parallel threads of control enter these functions which change the
state?  If so, then you need to make the state changes under the lock.
In fact, you probably have to make the state tests under the locks as
well.

If not, please explain what prevents it from happening.

Thanks.
