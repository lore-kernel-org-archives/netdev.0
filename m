From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix sock_wfree() race
Date: Fri, 11 Sep 2009 11:43:37 -0700 (PDT)
Message-ID: <20090911.114337.150207703.davem@davemloft.net>
References: <df9815e70909080109r3d61ee76v3dcba41dbd87b998@mail.gmail.com>
	<4AA64A11.7090804@gmail.com>
	<4AA6DF7B.7060105@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: albcamus@gmail.com, parag.lkml@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54126
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755766AbZIKSnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 14:43:21 -0400
In-Reply-To: <4AA6DF7B.7060105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Sep 2009 00:49:31 +0200

> [PATCH] net: Fix sock_wfree() race
> 
> Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
> (net: No more expensive sock_hold()/sock_put() on each tx)
> opens a window in sock_wfree() where another cpu
> might free the socket we are working on.
> 
> Fix is to call sk->sk_write_space(sk) only
> while still holding a reference on sk.
> 
> Since doing this call is done before the 
> atomic_sub(truesize, &sk->sk_wmem_alloc), we should pass truesize as 
> a bias for possible sk_wmem_alloc evaluations.
> 
> Reported-by: Jike Song <albcamus@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks.  I'll queue up your simpler
version for -stable.

BTW, if most if not all of the sock_writeable() calls are now
sock_writeable_bias(), it's probably better to just add the
bias argument to sock_writable().

And a quick grep shows that only a few plain sock_writeable()
calls remain in the less often used protocols.
