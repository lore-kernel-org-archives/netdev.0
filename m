From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Sat, 29 Sep 2007 13:20:08 +0800
Message-ID: <20070929052008.GA1192@gondor.apana.org.au>
References: <46FD0117.9030407@hitachi.com> <E1IbSt7-000091-00@gondolin.me.apana.org.au> <20070928.214737.120464821.davem@davemloft.net> <20070928.215159.58440039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: satoshi.oshima.fk@hitachi.com, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, haoki@redhat.com, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2598 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752729AbXI2FUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 01:20:15 -0400
Content-Disposition: inline
In-Reply-To: <20070928.215159.58440039.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 28, 2007 at 09:51:59PM -0700, David Miller wrote:
> 
> There is a per-socket send buffer limit, and there is a per-user open
> file descriptor limit.  Multiply the two to determine how much system
> memory the user can consume using sockets.

We do have these limits but they're per-process, not per-user.
Unless you lock down the number of processes each user can have
to no more than a handful then this is basically useless.

For example, let's say each socket can lock down 64K of kernel
memory (which is quite easy to do BTW, just open a TCP/UDP socket,
send data to it from another socket but keep the data in the
socket by not calling recvmsg), and that each process can have
1024 file descriptors (the default), then each process can pin

64K x 1024 = 64M

of memory.  So if the user can have 10 processes, then that's
640M of kernel memory that can be pinned down.  Usually the
process limit is at least 10 times higher.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
