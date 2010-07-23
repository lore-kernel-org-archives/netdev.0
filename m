From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Fri, 23 Jul 2010 21:37:22 +0900
Message-ID: <201007232137.DJD12929.JOMFFtSQLVOOFH@I-love.SAKURA.ne.jp>
References: <201007220502.o6M52GJU098071@www262.sakura.ne.jp>
	<20100721.220611.267376790.davem@davemloft.net>
	<201007222146.FGC09386.OFOtFQOVFMJSLH@I-love.SAKURA.ne.jp>
	<20100722.102251.165153819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100722.102251.165153819.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> The fact is going to remain that you will be unable to return data
> from recvmsg() to a blocking socket when ->poll() returns true even
> though data is in fact there in the socket receive queue.
> 
Maybe I misunderstood here.

Are you worrying that TOMOYO will no longer be able to deliver remaining
packets in a receive queue once a packet from address/port which is not
permitted to pick up reached the head of the receive queue?
(Please answer "yes" or "no" here.)

If your answer is "yes", I tolerate the side effect (i.e. applications have to
close and recreate the socket in order to resume receiving packets).
My preferred behavior is to drop the packet but you will not accept it.
I accept not to drop the packet if you can accept security_socket_pre_recvmsg().

If your answer is "no", let me restart from reconfirming requirements which
LSM hook for recvmsg() must satisfy, before continuing discussion on
security_socket_pre_recvmsg() hook.
