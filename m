From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/7] drivers/net/ehea/ehea_main.c: Release mutex in error
 handling code
Date: Wed, 30 Jul 2008 17:23:50 -0400
Message-ID: <4890DBE6.4080408@pobox.com>
References: <Pine.LNX.4.64.0807210957060.24625@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: raisch@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57050 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491AbYG3VYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 17:24:00 -0400
In-Reply-To: <Pine.LNX.4.64.0807210957060.24625@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> The mutex is released on a successful return, so it would seem that it
> should be released on an error return as well.
> 
> The semantic patch finds this problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @@
> expression l;
> @@
> 
> mutex_lock(l);
> ... when != mutex_unlock(l)
>     when any
>     when strict
> (
> if (...) { ... when != mutex_unlock(l)
> +   mutex_unlock(l);
>     return ...;
> }
> |
> mutex_unlock(l);
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

applied


