From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: don't zeroize sock->file on detach
Date: Thu, 09 Aug 2012 16:16:39 -0700 (PDT)
Message-ID: <20120809.161639.1789560369123168415.davem@davemloft.net>
References: <20120809124436.5156.26944.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org, rick.jones2@hp.com,
	ycheng@google.com, linux-kernel@vger.kernel.org
To: skinsbursky@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab2HIXQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 19:16:40 -0400
In-Reply-To: <20120809124436.5156.26944.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date: Thu, 09 Aug 2012 16:50:40 +0400

> This is a fix for bug, introduced in 3.4 kernel by commit
> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other things, replaced
> simple sock_put() by sk_release_kernel(). Below is sequence, which leads to
> oops for non-persistent devices:
> 
> tun_chr_close()
> tun_detach()				<== tun->socket.file = NULL
> tun_free_netdev()
> sk_release_sock()
> sock_release(sock->file == NULL)
> iput(SOCK_INODE(sock))			<== dereference on NULL pointer
> 
> This patch just removes zeroing of socket's file from __tun_detach().
> sock_release() will do this.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Ruan Zhijie <ruanzhijie@hotmail.com>
> Tested-by: Ruan Zhijie <ruanzhijie@hotmail.com>
> Acked-by: Al Viro <viro@ZenIV.linux.org.uk>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Applied, thanks.
