From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [UDP]: memory accounting in IPv4
Date: Thu, 20 Dec 2007 03:44:37 -0800 (PST)
Message-ID: <20071220.034437.126882771.davem@davemloft.net>
References: <47673195.80004@redhat.com>
	<476732B7.9040502@redhat.com>
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
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753185AbXLTLoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 06:44:38 -0500
In-Reply-To: <476732B7.9040502@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hideo AOKI <haoki@redhat.com>
Date: Mon, 17 Dec 2007 21:38:47 -0500

> This patch adds UDP memory usage accounting in IPv4.
> 
> Send buffer accounting is performed by IP layer, because skbuff is
> allocated in the layer.
> 
> Receive buffer is charged, when the buffer successfully received.
> Destructor of the buffer does uncharging and reclaiming, when the
> buffer is freed. To set destructor at proper place, we use
> __udp_queue_rcv_skb() instead of sock_queue_rcv_skb(). To maintain
> consistency of memory accounting, socket lock is used to free receive
> buffer in udp_recvmsg().
> 
> New packet will be add to backlog when the socket is used by user.
> 
> Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
> signed-off-by: Takahiro Yasui <tyasui@redhat.com>
> signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
> signed-off-by: Hideo Aoki <haoki@redhat.com>

We can't accept these changes, even once the other issues
are fixed, until IPV6 is supported as well.

It's pointless to support proper UDP memory accounting only
in IPV4 and not in IPV6 as well.
