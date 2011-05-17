From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: recvmmsg: Strip MSG_WAITFORONE when calling
 recvmsg
Date: Tue, 17 May 2011 15:38:28 -0400 (EDT)
Message-ID: <20110517.153828.1804367055800380672.davem@davemloft.net>
References: <20110517085924.3a47b8e2@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab1EQTif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:38:35 -0400
In-Reply-To: <20110517085924.3a47b8e2@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Tue, 17 May 2011 08:59:24 +1000

> 
> recvmmsg fails on a raw socket with EINVAL. The reason for this is
> packet_recvmsg checks the incoming flags:
> 
>         err = -EINVAL;
>         if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT|MSG_ERRQUEUE))
>                 goto out;
> 
> This patch strips out MSG_WAITFORONE when calling recvmmsg which
> fixes the issue.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Cc: stable@kernel.org [2.6.34+]
> ---
> 
> We could also add MSG_WAITFORONE to the raw socket recvmsg check, or
> just remove the check completely. Thoughts?

I think both should be done.

Tests like the one packet_recvmsg() is doing makes it really hard to
add new MSG_* flags generically (ie. by adding the flag and having
some generic socket operation all recvmsg() implementations call
process that flag bit in some way).

It should just explicitly check for the bits it doesn't support.

And recvmmsg() should clear the bit because it is a completely
internal thing.  It's similar to how we hide MSG_CMSG_COMPAT from
userspace.

Anyways I'll apply this patch, and feel free to submit the other
one.

Thanks.
