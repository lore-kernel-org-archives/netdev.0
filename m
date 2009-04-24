From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Fri, 24 Apr 2009 04:40:12 -0700 (PDT)
Message-ID: <20090424.044012.173997575.davem@davemloft.net>
References: <200904240207.n3O27Sb0096107@www262.sakura.ne.jp>
	<20090423.213542.03667490.davem@davemloft.net>
	<200904240526.n3O5QO01039109@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, greg@blekko.com
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904240526.n3O5QO01039109@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Fri, 24 Apr 2009 14:26:24 +0900

> OK. I understood that security_socket_post_recv_datagram() must not return
> -EAGAIN if a process calls recvmsg() after poll() said "ready".
> That will be also true for security_socket_recvmsg().
> 
> 
> Is it OK for security_socket_recvmsg()/security_socket_accept() to return
> an error other than -EAGAIN?
> (In other words, security_socket_recvmsg()/security_socket_accept() errors are
> one of "hard" errors?)

I think you really need to wrap your head around the fact that you
can't decide after you've accepted a packet, that it's no longer
acceptable.  Once it's in the socket's queue, and you tell the
application it's there at poll() time, you simply cannot reneg.

You just can't.

Otherwise you're breaking the whole premise upon which these UNIX
system calls are based.  This is how people use these things.

Are you beginning to understand the fundamental problems I have with
your work?
