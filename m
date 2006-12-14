From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic with the newly merged md5 signature support
Date: Wed, 13 Dec 2006 16:22:35 -0800 (PST)
Message-ID: <20061213.162235.21925707.davem@davemloft.net>
References: <45239.81.105.127.245.1165964614.squirrel@www.solinno.co.uk>
	<20061212.172935.106265967.davem@davemloft.net>
	<45575.81.105.127.245.1166053430.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53526
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751836AbWLNAWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 19:22:36 -0500
To: leigh@solinno.co.uk
In-Reply-To: <45575.81.105.127.245.1166053430.squirrel@www.solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Leigh Brown" <leigh@solinno.co.uk>
Date: Wed, 13 Dec 2006 23:43:50 -0000 (GMT)

> I just had to kill the parameter:-
> 
> --- net/ipv4/tcp.c.orig	2006-12-10 21:46:26.000000000 +0000
> +++ net/ipv4/tcp.c	2006-12-13 17:38:29.000000000 +0000
> @@ -2362,7 +2362,7 @@ struct tcp_md5sig_pool *__tcp_get_md5sig
>  EXPORT_SYMBOL(__tcp_get_md5sig_pool);
> 
>  void __tcp_put_md5sig_pool(void) {
> -	__tcp_free_md5sig_pool(tcp_md5sig_pool);
> +	tcp_free_md5sig_pool();
>  }
> 
>  EXPORT_SYMBOL(__tcp_put_md5sig_pool);
> 
> It still seems to me that it shouldn't be necessary to alloc and free
> the pool from tcp_(get|put)_md5sig_pool, as you'll always have alloc'd
> the pool before calculating the hash, but I'm happy enough as at least
> its working now.

Once a socket adds an MD5 signature, there will be at least a
single reference, so it won't get release until all sockets with
MD5 signatures are closed and released.

The quick hold/release cases are for transitory references to the
per-cpu MD5 pool, such as when sending resets or SYN+ACKs
