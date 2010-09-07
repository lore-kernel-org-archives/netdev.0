From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Mon, 06 Sep 2010 18:45:29 -0700 (PDT)
Message-ID: <20100906.184529.42787419.davem@davemloft.net>
References: <201009040931.o849VstI061086@www262.sakura.ne.jp>
	<1283597729.3402.16.camel@edumazet-laptop>
	<201009041134.o84BYS0E082227@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49146
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756032Ab0IGBpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:45:11 -0400
In-Reply-To: <201009041134.o84BYS0E082227@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 04 Sep 2010 20:34:28 +0900

> Subject: [PATCH] UNIX: Do not loop forever at unix_autobind().
> 
> We assumed that unix_autobind() never fails if kzalloc() succeeded.
> But unix_autobind() allows only 1048576 names. If /proc/sys/fs/file-max is
> larger than 1048576 (e.g. systems with more than 10GB of RAM), a local user can
> consume all names using fork()/socket()/bind().
> 
> If all names are in use, those who call bind() with addr_len == sizeof(short)
> or connect()/sendmsg() with setsockopt(SO_PASSCRED) will continue
> 
>   while (1)
>         yield();
> 
> loop at unix_autobind() till a name becomes available.
> This patch adds a loop counter in order to give up after 1048576 attempts.
> 
> Calling yield() for once per 256 attempts may not be sufficient when many names
> are already in use, for __unix_find_socket_byname() can take long time under
> such circumstance. Therefore, this patch also adds cond_resched() call.
> 
> Note that currently a local user can consume 2GB of kernel memory if the user
> is allowed to create and autobind 1048576 UNIX domain sockets. We should
> consider adding some restriction for autobind operation.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Applied and queued up for -stable, thanks!
