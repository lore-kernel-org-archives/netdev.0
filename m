From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] tcp: TCP_NOTSENT_LOWAT socket option
Date: Wed, 24 Jul 2013 17:55:22 -0700 (PDT)
Message-ID: <20130724.175522.1183139427742327918.davem@davemloft.net>
References: <1374550027.4990.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, ycheng@google.com,
	ncardwell@google.com, mtk.manpages@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523Ab3GYAzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:55:23 -0400
In-Reply-To: <1374550027.4990.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Jul 2013 20:27:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Idea of this patch is to add optional limitation of number of
> unsent bytes in TCP sockets, to reduce usage of kernel memory.
> 
> TCP receiver might announce a big window, and TCP sender autotuning
> might allow a large amount of bytes in write queue, but this has little
> performance impact if a large part of this buffering is wasted :
> 
> Write queue needs to be large only to deal with large BDP, not
> necessarily to cope with scheduling delays (incoming ACKS make room
> for the application to queue more bytes)
> 
> For most workloads, using a value of 128 KB or less is OK to give
> applications enough time to react to POLLOUT events in time
> (or being awaken in a blocking sendmsg())
> 
> This patch adds two ways to set the limit :
> 
> 1) Per socket option TCP_NOTSENT_LOWAT
> 
> 2) A sysctl (/proc/sys/net/ipv4/tcp_notsent_lowat) for sockets
> not using TCP_NOTSENT_LOWAT socket option (or setting a zero value)
> Default value being UINT_MAX (0xFFFFFFFF), meaning this has no effect.
> 
> 
> This changes poll()/select()/epoll() to report POLLOUT 
> only if number of unsent bytes is below tp->nosent_lowat
> 
> Note this might increase number of sendmsg()/sendfile() calls
> when using non blocking sockets,
> and increase number of context switches for blocking sockets.
> 
> Note this is not related to SO_SNDLOWAT (as SO_SNDLOWAT is
> defined as :
>  Specify the minimum number of bytes in the buffer until
>  the socket layer will pass the data to the protocol)
> 
> Tested:
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied
