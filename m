From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 20:39:08 +0900
Message-ID: <200904212039.JID59468.LOFOtMQOFJFSVH@I-love.SAKURA.ne.jp>
References: <200904181734.ACB09871.QtVSOHMFJOLFOF@I-love.SAKURA.ne.jp>
	<200904201822.29529.paul.moore@hp.com>
	<200904211954.GGC13036.FFJLtOMHOVSOQF@I-love.SAKURA.ne.jp>
	<20090421.035731.200252490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421.035731.200252490.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> There is no sane way for the user to handle this connection
> being aborted, and there is no way to insert the connection
> back into the listening socket queue once we get to this
> point so we can't replay this situation either.
> 
Excuse me, I couldn't catch.

I don't have a problem that there is no way to insert the connection back into
the listening socket queue once we get to this point. I want to drop the
connection rather than pushing the connection back to the queue.

I meant that "if we allow doing something after sock->ops->accept(), we need to
drop the connection if something returned an error". An example of something is
to assign/modify state. To modify task's state, I need to allocate memory for
new credential which is an operation that could fail.
Therefore, the socket_post_accept() hook should allow aborting the connection.

Paul doesn't like using the socket_post_accept() hook to abort connections.
But the connection is aborted if either newsock->ops->getname() or
move_addr_to_user() returned an error. I wonder what's so problematic with
using socket_post_accept() for dropping the connection.
