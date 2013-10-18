From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] {selinux, af_key} Rework
 pfkey_sadb2xfrm_user_sec_ctx
Date: Fri, 18 Oct 2013 15:58:33 -0400 (EDT)
Message-ID: <20131018.155833.1412406960170647411.davem@davemloft.net>
References: <1381904114-29556-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab3JRT6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 15:58:34 -0400
In-Reply-To: <1381904114-29556-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Wed, 16 Oct 2013 14:15:14 +0800

> Taking advantages of sadb_x_sec_ctx and xfrm_user_sec_ctx share the same
> structure arrangement, rework pfkey_sadb2xfrm_user_sec_ctx by casting
> sadb_x_sec_ctx into xfrm_user_sec_ctx with minor len fix.
> 
> Then we can:
>  -Avoid kmalloc/free memory for xfrm_user_sec_ctx, sadb_x_sec_ctx would be fine.
>  -Fix missing return value check bug for pfkey_compile_policy when kmalloc fails
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

This isn't safe, one structure is packed and the other is not.

Furthermore, unless there is some enormous gain (in this case there
is not) losing the type checking by casting two data structures like
this is undesirable.
