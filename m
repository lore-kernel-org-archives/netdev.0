From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 21:22:59 -0700 (PDT)
Message-ID: <20090421.212259.213941533.davem@davemloft.net>
References: <200904220055.n3M0tQ6T048840@www262.sakura.ne.jp>
	<20090421.181411.26595688.davem@davemloft.net>
	<200904220149.n3M1ngLa059958@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750751AbZDVEXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 00:23:07 -0400
In-Reply-To: <200904220149.n3M1ngLa059958@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Wed, 22 Apr 2009 10:49:42 +0900

> David Miller wrote:
>> We had a similar situation with read()'s on UDP sockets.
>> 
>> When poll() says something, it has to stick.
> To adhere what poll() said (i.e. "connections are ready" or "datagrams are
> ready"), security_socket_accept() and security_socket_recvmsg() hooks must be
> removed. Otherwise, LSM users cannot adhere what poll() said.
> 
> However, security_socket_accept() and security_socket_recvmsg() hooks remain
> there. LSM users are already using semantics which may not adhere what poll()
> said.

So what does your TOMOTO stuff do if the mapping changes again and
that incoming connection that became unacceptable is now acceptable?

We've lost the connection, and can never get it back.

These semantics don't make any sense at all, and the point at which
you make your choices here is totally arbitrary.

Read that carefully: the point at which you are making this
drop decision is arbitrary.
