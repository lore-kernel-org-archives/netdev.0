From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Cleanup of af_unix
Date: Sun, 16 Nov 2008 22:32:09 -0800 (PST)
Message-ID: <20081116.223209.239966240.davem@davemloft.net>
References: <49210AE7.3050405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751554AbYKQGcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:32:10 -0500
In-Reply-To: <49210AE7.3050405@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 07:10:47 +0100

> @@ -1998,7 +1990,8 @@ static unsigned int unix_poll(struct file * file, struct socket *sock, poll_tabl
>  		mask |= POLLIN | POLLRDNORM;
>  
>  	/* Connection-based need to check for termination and startup */
> -	if ((sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) && sk->sk_state == TCP_CLOSE)
> +	if ((sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) &&
> +		sk->sk_state == TCP_CLOSE)
>  		mask |= POLLHUP;
>  
>  	/*

This should instead be:

	if ((sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) &&
	    sk->sk_state == TCP_CLOSE)

> Some long lines (over 80 columns) were not changed, please tell me if you prefer
> them go.

I'm ambivalent, at which point it's just noise and merge hassles, so let's
just leave it alone.

