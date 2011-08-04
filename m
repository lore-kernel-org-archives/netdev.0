From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Thu, 4 Aug 2011 22:56:15 +1000
Message-ID: <20110804225615.5aa64d74@kryten>
References: <201108030325.p733Pplb030986@www262.sakura.ne.jp>
	<20110802.203836.40056483416201909.davem@davemloft.net>
	<20110803134752.31347b64@kryten>
	<201108032120.CHC60420.OVOFQFHMJLSOtF@I-love.SAKURA.ne.jp>
	<20110803232957.5e7a5d0a@kryten>
	<201108040650.JIF90138.tFLHFJOSFOQMOV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eparis@parisplace.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201108040650.JIF90138.tFLHFJOSFOQMOV@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

> > [PATCH] net: Cap number of elements for recvmmsg and sendmmsg
> > 
> > To limit the amount of time we can spend in recvmmsg and sendmmsg,
> > cap the number of elements to UIO_MAXIOV (currently 1024).
> 
> Looks reasonable value. But it will return less than requested
> without setting error code. Programmers would needlessly call
> getsockopt(SO_ERROR) and get 0. Maybe -EINVAL or something is better
> than returning less than requested?

Having to call getsockopt(SO_ERROR) at all is confusing. We should
change sendmmsg to only return an error if no messages are sent. If we
do this, then the application will have already have to handle the case
where we send less messages than requested.

Returning EINVAL adds complexity to the system call that I think we
should avoid. Will send out the patches for review after some sleep.

Anton
