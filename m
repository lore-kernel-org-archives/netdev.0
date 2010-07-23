From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Fri, 23 Jul 2010 09:22:20 +0900
Message-ID: <201007230022.o6N0MKLt053955@www262.sakura.ne.jp>
References: <20100721.220611.267376790.davem@davemloft.net> <201007222146.FGC09386.OFOtFQOVFMJSLH@I-love.SAKURA.ne.jp> <20100722.102251.165153819.davem@davemloft.net> <20100722.102637.201684445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:52582 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756577Ab0GWAWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 20:22:23 -0400
In-Reply-To: <20100722.102637.201684445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> The fact is going to remain that you will be unable to return data
> from recvmsg() to a blocking socket when ->poll() returns true even
> though data is in fact there in the socket receive queue.
> 
> This is something that the existing LSM hooks do not do.

This is something that the existing security_socket_recvmsg() hook does do.
SELinux is unable to return data from recvmsg() to a blocking socket when
->poll() returns true even though data is in fact there in the socket receive
queue.
We agreed below situation, didn't we?

Tetsuo Handa wrote:
> > > Excuse me, below check is made inside recvmsg() and may return error if
> > > SELinux's policy has changed after the select() said "ready" and before
> > > security_socket_recvmsg() is called. No?
> > 
> > It does this before pulling the packet out of the receive queue of the
> > socket.  It's like signalling a parameter error to the process, no
> > socket state is changed.
> 
> So, we agreed that security_socket_recvmsg() is allowed to return error code
> rather than available data even if both conditions
> 
> 1) Application makes poll() on UDP socket in blocking mode, and UDP
>    reports that receive data is available
> 
> and
> 
> 2) Application, after such a poll() call, makes a blocking recvmsg() call
>    and no other activity has occurred on the socket meanwhile
> 
> are met.
