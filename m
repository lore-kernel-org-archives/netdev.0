From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 18:14:11 -0700 (PDT)
Message-ID: <20090421.181411.26595688.davem@davemloft.net>
References: <200904212152.FHH51019.MHOFVtOFSJFQOL@I-love.SAKURA.ne.jp>
	<20090421.060404.146628527.davem@davemloft.net>
	<200904220055.n3M0tQ6T048840@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904220055.n3M0tQ6T048840@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Wed, 22 Apr 2009 09:55:26 +0900

> David Miller wrote:
>> If poll() says to a listening socket that connections are
>> available, we MUST return a connection from accept() unless
>> there is a hard error.
> 
> No application is permitted to assume that accept() returns a connection if
> poll() says that connections are available even if there is an assumption that
> none of sock->ops->accept(), newsock->ops->getname(), move_addr_to_user()
> fails, for there is security_socket_accept() hook which can interrupt between
> "poll()" and "accept()".
> 
> There is a possibility that LSM module's policy changes from "allow picking
> the connection up from the listening socket" to "deny picking the connection
> up from the listening socket" after poll() said "connections are available".
> We allow this policy change and we tolerate breakage of the application
> expected semantics.

We had a similar situation with read()'s on UDP sockets.

When poll() says something, it has to stick.

This is not discussable.  If these semantics are "necessary", then
what you're doing is definitely misdesigned in my opinion.

