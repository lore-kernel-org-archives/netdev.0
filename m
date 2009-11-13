From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH v6 2/7 RFC] TCPCT part 1b: generate
 Responder Cookie
Date: Fri, 13 Nov 2009 10:04:17 -0800
Message-ID: <1258135457.16857.107.camel@Joe-Laptop.home>
References: <4AFCDA9E.8050003@gmail.com>  <4AFCDDC4.1090606@gmail.com>
	 <1258093594.16857.43.camel@Joe-Laptop.home>  <4AFD728F.4030206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1040 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756413AbZKMSEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 13:04:12 -0500
In-Reply-To: <4AFD728F.4030206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-11-13 at 09:51 -0500, William Allen Simpson wrote:
> Since Eric says it can be inside the locked path, I can do away with
> that entirely, and just use the result (bakery) pointer itself.  Saves a
> memcpy, too.
> Here's my revised attempt (untested).  Any other technical corrections?

Just one, thanks for persisting.

> +	if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
> +		spin_lock_bh(&tcp_secret_locker);
> +		if (!time_after_eq(jiffy, tcp_secret_generating->expires)) {
[]
> +			spin_unlock_bh(&tcp_secret_locker);
> +		} else {
[]
> +			spin_unlock_bh(&tcp_secret_locker);
[removed comments]
> +		}

perhaps deleting the two unlocks above and moving it
to the same indent level here is trivially better.

		spin_unlock_bh(&tcp_secret_locker);


