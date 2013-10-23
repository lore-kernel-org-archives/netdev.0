From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] net: add missing dev_put() in
 __netdev_adjacent_dev_insert
Date: Wed, 23 Oct 2013 15:36:52 +0200
Message-ID: <20131023133652.GF25073@redhat.com>
References: <1382534936-23080-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936Ab3JWNjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 09:39:04 -0400
Content-Disposition: inline
In-Reply-To: <1382534936-23080-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 03:28:56PM +0200, Nikolay Aleksandrov wrote:
>I think that a dev_put() is needed in the error path to preserve the
>proper dev refcount.

True, forgot about it. Thanks for spotting this!

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>
>CC: Veaceslav Falico <vfalico@redhat.com>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> net/core/dev.c | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 0918aad..bdffd65 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4648,6 +4648,7 @@ remove_symlinks:
>
> free_adj:
> 	kfree(adj);
>+	dev_put(adj_dev);
>
> 	return ret;
> }
>-- 
>1.8.1.4
>
