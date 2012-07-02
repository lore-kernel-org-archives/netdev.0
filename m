From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ipv6: remove unnecessary codes in
 tcp_ipv6.c
Date: Mon, 02 Jul 2012 10:54:41 +0200
Message-ID: <1341219281.5269.36.camel@edumazet-glaptop>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
	 <20120701.202610.12425223200611171.davem@davemloft.net>
	 <1341216816.5269.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42196 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932170Ab2GBIyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 04:54:46 -0400
Received: by eaak11 with SMTP id k11so1982105eaa.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 01:54:44 -0700 (PDT)
In-Reply-To: <1341216816.5269.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 10:13 +0200, Eric Dumazet wrote:

> Note that the old one is the np->opt of the listener, not the child.
> 
> I dont understand how np->opt could change under us, since we have
> the listener socket locked.
> 
> If np->opt can change under us, we are doomed and need to add refcounts.

Hmm, it seems net/ipv6/udp.c uses np->opt outside of the
lock_sock()/release_sock(sk) boundary.
