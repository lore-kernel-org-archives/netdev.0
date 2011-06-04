From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Sat, 04 Jun 2011 13:34:38 -0700 (PDT)
Message-ID: <20110604.133438.1450652272927306428.davem@davemloft.net>
References: <1306288567-1773-1-git-send-email-maheshb@google.com>
	<1306363336-13614-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, mirqus@gmail.com,
	shemminger@vyatta.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863Ab1FDUeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2011 16:34:44 -0400
In-Reply-To: <1306363336-13614-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 25 May 2011 15:42:16 -0700

> Little bit cleanup by defining enum for all bits used. Also use those enum
> values to redefine flags.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> Changes since v2:
>  (1) Removed the include which was part of the other patch (split mishap).
>  (2) Changed the enums to add NETIF_F_ prefix.

I hate to be a pain after you've put so much work into these patches,
but I simply don't like this approach.

I think the abstracted interfaces should come first.  You don't need to
change any of the NETIF_F_* defines in order to do that.  You should only
need to add the netdev_{set,clear,test}_*() macros.

If you want you can make the "bit" argument be the flag name after the
NETIF_F_ prefix, so "netdev_test_active_feature(dev, SG)"

Then you convert every single access.

Then you make the flags type opaque, which should at that point be a
6 line change at best.

And then you can implement the flags however you want.
