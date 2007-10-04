From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix kernel_accept() error path
Date: Thu, 04 Oct 2007 16:55:59 -0700 (PDT)
Message-ID: <20071004.165559.123919608.davem@davemloft.net>
References: <47054AF5.4050409@cybernetics.com>
	<Xine.LNX.4.64.0710041456300.13076@us.intercode.com.au>
	<47056565.50803@cybernetics.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org
To: tonyb@cybernetics.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42674
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758184AbXJDX4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 19:56:00 -0400
In-Reply-To: <47056565.50803@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tony Battersby <tonyb@cybernetics.com>
Date: Thu, 04 Oct 2007 18:12:53 -0400

> Here is an example of what I would consider "reasonable code" that would
> fail:
> 
> int example()
> {
>     struct socket *conn_socket = NULL;
>     int err;
> 
>     ...
> 
>     if ((err = kernel_accept(sock, &conn_socket, 0)) < 0)
>         goto out_cleanup;
> 
>     [do whatever with conn_socket]
> 
>  out_cleanup:
> 
>     if (conn_socket != NULL)
>         sock_release(&conn_socket);
> 
>     return err;
> }

This is a grey area.

I'd say you shouldn't be trying to do cleanups on conn_socket unless
kernel_accept() gave you a success return.

However, kernel_accept() is guilty of leaving a stray pointer
in conn_socket, in fact a reference to freed memory.  So
from that perspective we should put your patch in.

Please resubmit, at least to me under seperate cover,thanks.
