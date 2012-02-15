From: David Miller <davem@davemloft.net>
Subject: Re: Possible bugfix for AF_UNIX, SOCK_SEQPACKET sockets
Date: Wed, 15 Feb 2012 14:55:11 -0500 (EST)
Message-ID: <20120215.145511.1269077904303781879.davem@davemloft.net>
References: <1329287109.2555.44.camel@edumazet-laptop>
	<CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
	<1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: piergiorgio.beruto@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595Ab2BOTzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 14:55:14 -0500
In-Reply-To: <1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Feb 2012 13:42:07 +0100

> @@ -1824,7 +1824,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
>  		if (UNIXCB(skb).fp)
>  			siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
>  	}
> -	err = size;
> +	err = (flags & MSG_TRUNC) ? skb->len : size;
>  
>  	scm_recv(sock, msg, siocb->scm, flags);

I'm ok with this, but if it is found to break even one userland application
I'm reverting with impunity.
