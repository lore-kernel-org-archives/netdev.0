From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() andsecurity_socket_post_recv_datagram().
Date: Fri, 24 Apr 2009 22:57:27 +0900
Message-ID: <200904242257.DJI04626.OJSMFOQVFOFLHt@I-love.SAKURA.ne.jp>
References: <200904240207.n3O27Sb0096107@www262.sakura.ne.jp>
	<20090423.213542.03667490.davem@davemloft.net>
	<200904240526.n3O5QO01039109@www262.sakura.ne.jp>
	<20090424.044012.173997575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, greg@blekko.com
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090424.044012.173997575.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Are you beginning to understand the fundamental problems I have with
> your work?
You are saying that we must not discard what we have in the queue after we told
somebody that we have something in the queue unless we get "hard" errors.

> If poll() says to a listening socket that connections are
> available, we MUST return a connection from accept() unless
> there is a hard error.
I haven't understood what you meant by a "hard" error. What I want to know is,
are errors returned by security_socket_accept() and security_socket_recvmsg()
"hard" errors?

If these errors are not "hard" errors, security_socket_accept() and
security_socket_recvmsg() must not return an error because it will result in
"not returning a connection/datagram", for you are saying that only "hard"
errors can justify "not returning a connection/datagram".

If these errors are "hard" errors, security_socket_accept() and
security_socket_recvmsg() can justify "not returning a connection/datagram".
But errors by newsock->ops->getname() or move_addr_to_user() (these are also
"hard" errors, aren't they?) justified "discarding a connection/datagram".
Then, if a "hard" error was returned by LSM hooks after a connection/datagram
was dequeued, I think we can justify "discarding that connection/datagram".
