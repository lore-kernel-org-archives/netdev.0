From: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>
Subject: Re: [RFC] Allow LSM to use IP address/port number.
Date: Mon, 9 Jul 2007 22:13:52 +0900
Message-ID: <200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp>
References: <200707070225.AFC45609.MNStNTPG@I-love.SAKURA.ne.jp>
	<200707061343.03942.paul.moore@hp.com>
	<200707090533.l695X1PM059672@www262.sakura.ne.jp>
	<20070709.002629.28788394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20070709.002629.28788394.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Thank you for your comment.


David Miller wrote:
> I don't think it's such a hot idea to return errors if the
> wait_on_sync_kiocb() has returned success.
My patch may return errors for non-wait_on_sync_kiocb() case too.
Are you saying only wait_on_sync_kiocb() case is bad?
If so, could you please explain me why?
The location I inserted a hook is "after aio event finished".
Both "struct kiocb" and "struct sock_iocb" are no longer in use.
So, I think this location can safely return errors.


If you are saying "don't return error after receiving data",
I'll explain you why I need hooks after receiving data.

What I want to do is to implement a kind of anti-virus software's
personal firewall feature.
It drops messages from unwanted IP address/ports.
(To be exact, it doesn't drop, it just tells userland process
not to use received messages by returning errors.)

security_socket_recvmsg() is called before retrieving a message.
I want a hook that is called after retrieving a message
so that I can use IP address and port number for judgement.

I also want to allow users judge interactively using a popup dialog.
To judge interactively, the hook has to be block-able.
If non-interactive, iptables is the appropriate location for filtering.
This is why I want to insert security_socket_post_recvmsg() hook here.


Regards.
