From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ipv6: remove unnecessary codes in
 tcp_ipv6.c
Date: Mon, 02 Jul 2012 10:13:36 +0200
Message-ID: <1341216816.5269.32.camel@edumazet-glaptop>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
	 <20120701.202610.12425223200611171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44952 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab2GBINj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 04:13:39 -0400
Received: by eaak11 with SMTP id k11so1967610eaa.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 01:13:38 -0700 (PDT)
In-Reply-To: <20120701.202610.12425223200611171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-01 at 20:26 -0700, David Miller wrote:
> From: roy.qing.li@gmail.com
> Date: Mon,  2 Jul 2012 11:18:59 +0800
> 
> > -	if (opt) {
> > -		newnp->opt = ipv6_dup_options(newsk, opt);
> > -		if (opt != np->opt)
> > -			sock_kfree_s(sk, opt, opt->tot_len);
> 
> This is bogus, if we copy the options into a new copy in
> ipv6_dup_options() we have to free the old one or else we
> leak it.

Note that the old one is the np->opt of the listener, not the child.

I dont understand how np->opt could change under us, since we have
the listener socket locked.

If np->opt can change under us, we are doomed and need to add refcounts.
