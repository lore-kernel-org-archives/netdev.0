From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] [UDP]: memory accounting and limitation (take 10)
Date: Sat, 15 Dec 2007 21:34:26 -0800 (PST)
Message-ID: <20071215.213426.257974943.davem@davemloft.net>
References: <47636120.4050701@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbXLPFe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 00:34:27 -0500
In-Reply-To: <47636120.4050701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hideo AOKI <haoki@redhat.com>
Date: Sat, 15 Dec 2007 00:07:44 -0500

> Changelog take 9 -> take 10:
>  * supported using sk_forward_alloc
>  * introduced several memory accounting functions with spin lock
>  * changed detagram receive functions to be able to customize
>    destructor
>  * fixed accounting bugs in previous takes

This is not what Herbert and I meant with our suggestion.

We meant to convert all of UDP and datagram handling to lock
sockets precisely like TCP does, by calling lock_sock()
on entry to functions like udp_recvmsg() and release_sock()
on exit from those functions.

Then in the packet input processing, a sequence, just like
TCP, such as:

	bh_lock_sock_nested(sk);
	if (!sock_owned_by_user(sk)) {
		udp_do_rcv(sk, skb);
	} else
		sk_add_backlog(sk, skb);

Then a suitably defined ->backlog_rcv is hooked up for these
protocols as well.

Again, use TCP as a guide.

There is much more work involved to implement this properly,
and make the accounting code sharable with TCP, than the
simplistic and minimal spin lock code you added here.

Please do this correctly, thank you.
