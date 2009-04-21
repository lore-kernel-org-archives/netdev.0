From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 03:57:31 -0700 (PDT)
Message-ID: <20090421.035731.200252490.davem@davemloft.net>
References: <200904181734.ACB09871.QtVSOHMFJOLFOF@I-love.SAKURA.ne.jp>
	<200904201822.29529.paul.moore@hp.com>
	<200904211954.GGC13036.FFJLtOMHOVSOQF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904211954.GGC13036.FFJLtOMHOVSOQF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 21 Apr 2009 19:54:06 +0900

> Paul Moore wrote:
>> > The security_socket_post_accept() hook is used for not only
>> > aborting TCP connections from unwanted peers but also associating client's
>> > information with a process who handles that TCP connection. The task's state
>> > variable definitely requires a LSM hook which is called after sock->ops->
>> > accept() call.
>> 
>> I don't have a problem with using a socket_post_accept() hook to assign/modify 
>> state, however, I still not like the idea of using the socket_post_accept()
>> hook to abort connections.
> 
> What do you think that assigning/modifying state at socket_post_accept() could
> fail?

I have to agree with Paul.

There is no sane way for the user to handle this connection
being aborted, and there is no way to insert the connection
back into the listening socket queue once we get to this
point so we can't replay this situation either.
