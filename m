From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Thu, 4 Aug 2011 06:50:27 +0900
Message-ID: <201108040650.JIF90138.tFLHFJOSFOQMOV@I-love.SAKURA.ne.jp>
References: <201108030325.p733Pplb030986@www262.sakura.ne.jp>
	<20110802.203836.40056483416201909.davem@davemloft.net>
	<20110803134752.31347b64@kryten>
	<201108032120.CHC60420.OVOFQFHMJLSOtF@I-love.SAKURA.ne.jp>
	<20110803232957.5e7a5d0a@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eparis@parisplace.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: anton@samba.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110803232957.5e7a5d0a@kryten>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
> [PATCH] net: Cap number of elements for recvmmsg and sendmmsg
> 
> To limit the amount of time we can spend in recvmmsg and sendmmsg,
> cap the number of elements to UIO_MAXIOV (currently 1024).

Looks reasonable value. But it will return less than requested without setting
error code. Programmers would needlessly call getsockopt(SO_ERROR) and get 0.
Maybe -EINVAL or something is better than returning less than requested?
