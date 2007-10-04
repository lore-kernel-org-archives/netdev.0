From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] net: fix kernel_accept() error path
Date: Thu, 4 Oct 2007 14:57:33 -0700 (PDT)
Message-ID: <Xine.LNX.4.64.0710041456300.13076@us.intercode.com.au>
References: <47054AF5.4050409@cybernetics.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Tony Battersby <tonyb@cybernetics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:37894 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762167AbXJDV5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 17:57:39 -0400
In-Reply-To: <47054AF5.4050409@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Oct 2007, Tony Battersby wrote:

> If accept() returns an error, kernel_accept() releases the new socket
> but passes a pointer to the released socket back to the caller.  Make it
> pass back NULL instead.
> 
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
> ---
> --- linux-2.6.23-rc9/net/socket.c.bak	2007-10-04 15:21:17.000000000 -0400
> +++ linux-2.6.23-rc9/net/socket.c	2007-10-04 15:21:22.000000000 -0400
> @@ -2230,6 +2230,7 @@ int kernel_accept(struct socket *sock, s
>  	err = sock->ops->accept(sock, *newsock, flags);
>  	if (err < 0) {
>  		sock_release(*newsock);
> +		*newsock = NULL;
>  		goto done;
>  	}
>  

If you get an error back from kernel_accept, you should not be trying to 
use newsock.

-- 
James Morris
<jmorris@namei.org>
