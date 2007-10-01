From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Mon, 01 Oct 2007 22:56:04 +0900
Message-ID: <4700FC74.6000601@hitachi.com>
References: <46FD0117.9030407@hitachi.com> <E1IbSt7-000091-00@gondolin.me.apana.org.au> <20070928.214737.120464821.davem@davemloft.net> <20070928.215159.58440039.davem@davemloft.net> <20070929052008.GA1192@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, haoki@redhat.com, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:39728 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbXJAN4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:56:08 -0400
Received: from mlsv18.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id CD82237ACB
	for <netdev@vger.kernel.org>; Mon,  1 Oct 2007 22:56:07 +0900 (JST)
In-Reply-To: <20070929052008.GA1192@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Sep 28, 2007 at 09:51:59PM -0700, David Miller wrote:
>> There is a per-socket send buffer limit, and there is a per-user open
>> file descriptor limit.  Multiply the two to determine how much system
>> memory the user can consume using sockets.
>
> We do have these limits but they're per-process, not per-user.
> Unless you lock down the number of processes each user can have
> to no more than a handful then this is basically useless.
>
> For example, let's say each socket can lock down 64K of kernel
> memory (which is quite easy to do BTW, just open a TCP/UDP socket,
> send data to it from another socket but keep the data in the
> socket by not calling recvmsg), and that each process can have
> 1024 file descriptors (the default), then each process can pin
>
> 64K x 1024 = 64M
>
> of memory.  So if the user can have 10 processes, then that's
> 640M of kernel memory that can be pinned down.  Usually the
> process limit is at least 10 times higher.

Thank you very mush for your comment.

What you pointed out is my motivation to make this patch.
I think that per-process limits won't help to solve this
problem.
