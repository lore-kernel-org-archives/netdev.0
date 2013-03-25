From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix: fix a race condition in unix_release()
Date: Mon, 25 Mar 2013 13:13:44 -0400 (EDT)
Message-ID: <20130325.131344.2141703890142351951.davem@davemloft.net>
References: <20130325131833.10376.68379.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jan.stancek@gmail.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756524Ab3CYRNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 13:13:46 -0400
In-Reply-To: <20130325131833.10376.68379.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 25 Mar 2013 09:18:33 -0400

> As reported by Jan, and others over the past few years, there is a
> race condition caused by unix_release setting the sock->sk pointer
> to NULL before properly marking the socket as dead/orphaned.  This
> can cause a problem with the LSM hook security_unix_may_send() if
> there is another socket attempting to write to this partially
> released socket in between when sock->sk is set to NULL and it is
> marked as dead/orphaned.  This patch fixes this by only setting
> sock->sk to NULL after the socket has been marked as dead; I also
> take the opportunity to make unix_release_sock() a void function
> as it only ever returned 0/success.
> 
> Dave, I think this one should go on the -stable pile.
> 
> Special thanks to Jan for coming up with a reproducer for this
> problem.
> 
> Reported-by: Jan Stancek <jan.stancek@gmail.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied, and queued up for -stable, thanks.
