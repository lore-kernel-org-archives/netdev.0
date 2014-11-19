From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4] ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Wed, 19 Nov 2014 23:12:21 +0100
Message-ID: <3682315.1qi3iAkNAF@wuerfel>
References: <1609909.1jJeqOzgZ8@wuerfel> <20141119.154400.1045032776950540216.davem@davemloft.net> <20141119220549.GA26133@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:51306 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933287AbaKSWMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 17:12:39 -0500
In-Reply-To: <20141119220549.GA26133@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 19 November 2014 23:05:49 Jiri Bohac wrote:
> This fixes an old regression introduced by commit
> b0d0d915 (ipx: remove the BKL).
> 
> When a recvmsg syscall blocks waiting for new data, no data can be sent on the
> same socket with sendmsg because ipx_recvmsg() sleeps with the socket locked.
> 
> This breaks mars-nwe (NetWare emulator):
> - the ncpserv process reads the request using recvmsg
> - ncpserv forks and spawns nwconn
> - ncpserv calls a (blocking) recvmsg and waits for new requests
> - nwconn deadlocks in sendmsg on the same socket 
> 
> Commit b0d0d915 has simply replaced BKL locking with
> lock_sock/release_sock. Unlike now, BKL got unlocked while
> sleeping, so a blocking recvmsg did not block a concurrent
> sendmsg.
> 
> Only keep the socket locked while actually working with the socket data and
> release it prior to calling skb_recv_datagram(). 
> 
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
