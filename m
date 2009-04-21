From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 19:54:06 +0900
Message-ID: <200904211954.GGC13036.FFJLtOMHOVSOQF@I-love.SAKURA.ne.jp>
References: <200904141944.JFE64074.FHtOMOFQLFJOVS@I-love.SAKURA.ne.jp>
	<200904161423.04414.paul.moore@hp.com>
	<200904181734.ACB09871.QtVSOHMFJOLFOF@I-love.SAKURA.ne.jp>
	<200904201822.29529.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904201822.29529.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore wrote:
> > The security_socket_post_accept() hook is used for not only
> > aborting TCP connections from unwanted peers but also associating client's
> > information with a process who handles that TCP connection. The task's state
> > variable definitely requires a LSM hook which is called after sock->ops->
> > accept() call.
> 
> I don't have a problem with using a socket_post_accept() hook to assign/modify 
> state, however, I still not like the idea of using the socket_post_accept()
> hook to abort connections.

What do you think that assigning/modifying state at socket_post_accept() could
fail?

TOMOYO 1.x never fails since task's state variable is directly attached to
"struct task_struct" but TOMOYO 2.x can fail since task's state variable will
be indirectly attached via current->cred->security and memory allocation
failure for new credential could occur. Though it unlikely fails, I have to
abort connections by returning an error at socket_post_accept() hook if failed.

I think the socket_post_accept() hook anyway need to be able to abort
connections. (Or prepare new credential at socket_accept() and add a hook for
discarding prepared credential when sock->ops->accept() returned an error?)

Regards.
