From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Wed, 22 Apr 2009 14:38:04 +0900
Message-ID: <200904220538.n3M5c4QI010548@www262.sakura.ne.jp>
References: <200904220149.n3M1ngLa059958@www262.sakura.ne.jp> <20090421.212259.213941533.davem@davemloft.net> <200904220502.n3M52GQj001957@www262.sakura.ne.jp> <20090421.220735.118831531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421.220735.118831531.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Do me a favor.  We have mechanisms by which you can queue up packets
> (even into userspace) to make policy decisions.
I know.
> 
> You can make your decision there, and if appropriate, reinject the
> packet back into the kernel input processing.
No I can't.
> 
> This is how netfilter ip_queue allows people to implement policies
> in userspace, and you could use it in the kernel and then need
> none of these ugly hooks.
I was suggested to use that approach in the past discussion.

I want to make policy decisions based on the "task_struct" who picks up
the connection/datagram.

The netfilter can't predict which "task_struct" will pick up the
connection/datagram. Nobody can predict it. Even security_socket_accept()
and security_socket_recvmsg() can't predict it.

If TOMOYO is allowed to make policy decisions based on the "task_struct" who
picks up the connection/datagram, the only possible approach is to introduce
security_socket_post_accept() and security_socket_post_recv_datagram().
