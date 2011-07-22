From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Fri, 22 Jul 2011 08:22:24 -0700 (PDT)
Message-ID: <20110722.082224.688620059032914637.davem@davemloft.net>
References: <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
	<201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>
	<201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: casey@schaufler-ca.com, anton@samba.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 23 Jul 2011 00:12:53 +0900

> I think the regression for SMACK can be fixed with below patch.
> 
> Should I pass nosec flags down to "struct security_operations"->sendmsg()
> so that SELinux checks sock_has_perm() for only once when multiple different
> destination's addresses are passed to sendmmsg()?
> 
> static int selinux_socket_sendmsg(struct socket *sock, struct msghdr *msg,
> 				  int size, int nosec)
> {
> 	return nosec ? 0 : sock_has_perm(current, sock->sk, SOCKET__WRITE);
> }

Ugh, this takes away a non-trivial part of the performance gain of
sendmmsg().

I would instead rather that you check ahead of time whether this
actually is a send to different addresses.  If they are all the
same, keep the nosec code path.
