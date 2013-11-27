From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [patch] net: clamp ->msg_namelen instead of returning an error
Date: Wed, 27 Nov 2013 19:42:47 +0000
Message-ID: <20131127194247.GA28400@dcvr.yhbt.net>
References: <20131127115120.GC20630@order.stressinduktion.org>
 <20131127124021.GA2025@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dcvr.yhbt.net ([64.71.152.64]:58862 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753338Ab3K0Tmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Nov 2013 14:42:47 -0500
Content-Disposition: inline
In-Reply-To: <20131127124021.GA2025@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> wrote:
> If kmsg->msg_namelen > sizeof(struct sockaddr_storage) then in the
> original code that would lead to memory corruption in the kernel if you
> had audit configured.  If you didn't have audit configured it was
> harmless.
> 
> There are some programs such as beta versions of Ruby which use too
> large of a buffer and returning an error code breaks them.  We should
> clamp the ->msg_namelen value instead.
> 
> Reported-by: Eric Wong <normalperson@yhbt.net>

Thanks Dan, Ruby trunk r43886 works out-of-the-box with this fix.
Dave: please queue for stable, thanks

Tested-by: Eric Wong <normalperson@yhbt.net>

> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
