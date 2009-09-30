From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix sock_wfree() race
Date: Wed, 30 Sep 2009 16:23:16 -0700 (PDT)
Message-ID: <20090930.162316.123663794.davem@davemloft.net>
References: <4ABA262F.9040407@gmail.com>
	<4ABBD18A.70208@gmail.com>
	<4ABBDB54.4000609@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, albcamus@gmail.com, parag.lkml@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754761AbZI3XW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 19:22:57 -0400
In-Reply-To: <4ABBDB54.4000609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Sep 2009 22:49:24 +0200

> [PATCH] net: Fix sock_wfree() race
> 
> Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
> (net: No more expensive sock_hold()/sock_put() on each tx)
> opens a window in sock_wfree() where another cpu
> might free the socket we are working on.
> 
> A fix is to call sk->sk_write_space(sk) while still
> holding a reference on sk.
> 
> 
> Reported-by: Jike Song <albcamus@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6 and I'll queue this up for -stable.

Thanks!
