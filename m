From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Thu, 23 Apr 2009 21:35:42 -0700 (PDT)
Message-ID: <20090423.213542.03667490.davem@davemloft.net>
References: <20090422061006.GB27688@bx9.net>
	<20090421.233403.83067664.davem@davemloft.net>
	<200904240207.n3O27Sb0096107@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, greg@blekko.com
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755195AbZDXEft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 00:35:49 -0400
In-Reply-To: <200904240207.n3O27Sb0096107@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Fri, 24 Apr 2009 11:07:28 +0900

> David Miller wrote:
>> People use poll() to avoid -EAGAIN and blocking, they expect the bits
>> to tell them what fd's they can work on to do real work.
> 
> I found that "man 2 select" says
> 
>   Under Linux, select() may report a socket file descriptor as "ready for
>   reading", while nevertheless a subsequent read blocks. This could for example
>   happen when data has arrived but upon examination has wrong checksum and is
>   discarded.

You won't give up will you?  If you're trying to irritate me, it's
working.

This behavior mentioned in that manpage snippet is a BUG which we
FIXED!  You're just proving my point even more!

The poll() paths now cause a bypass of the delayed checksum
verification, which used to cause that above mentioned incorrect
behavior.

Don't push man page crap at me.  Instead, actually understand what the
code does and how it behaves.

This man page snipped above is completely wrong and buggy.  Never
trust documentation over code.
