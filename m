From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] fix sk->sk_filter field access
Date: Thu, 31 Aug 2006 03:14:06 +0400
Message-ID: <20060830231406.GA25736@ms2.inr.ac.ru>
References: <200608301707.14250.dim@openvz.org> <20060830.143015.104035096.davem@davemloft.net> <20060830222042.GA21714@ms2.inr.ac.ru> <20060830.153259.59653494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dim@openvz.org, netdev@vger.kernel.org, dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:15323 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751618AbWH3XOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 19:14:23 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060830.153259.59653494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Really?
>
> It is used with needlock=0 by DCCP ipv6, for example.  This case seems
> correct too.  What about sk_receive_skb()?  dn_queue_skb()?  In fact,
> there seems to be numerous uses still with needlock=0, all legitimate.

Well, not quite legitime.

sk_receive_skb() has the same bug as tcp_v4_rcv().

Call in backlog processing of ipv6/dccp is occasionally forgotten
duplicate of one done in sk_receive_skb().

Yes, those places really added a bit to desire to get rid of
this misuse of bh_lock_sock(). :-)


> Let us to fix bugs first, and then consider rewriting the locking.

To be honest, I think switching to RCU is the simplest bug fix.
At least, it does not require to search where bh_lock_sock() is taken
dn_queue_skb(), if it is not forgotten at all. :-)

Alexey
