From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Sat, 23 Jul 2011 03:31:24 +0900
Message-ID: <201107230331.GHE48423.QFHJMFOLtOOSVF@I-love.SAKURA.ne.jp>
References: <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
	<201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>
	<201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>
	<20110722.082224.688620059032914637.davem@davemloft.net>
	<201107230242.HJH39096.OSMOVQOLFFFHJt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: casey@schaufler-ca.com, anton@samba.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107230242.HJH39096.OSMOVQOLFFFHJt@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> David Miller wrote:
> > Ugh, this takes away a non-trivial part of the performance gain of
> > sendmmsg().
> > 
> > I would instead rather that you check ahead of time whether this
> > actually is a send to different addresses.  If they are all the
> > same, keep the nosec code path.
> > 
> OK. Something like this? Not tested at all.

No. We can't compare destination address before entering __sys_sendmsg(), for
it is copied to kernel memory by verify_iovec()/verify_compat_iovec().

To be able to compare, we need to pass "struct sockaddr_storage address;" to
__sys_sendmsg(). Also, the content the kernel has to hold is not array of
"struct msghdr" but array of "struct sockaddr_storage".
It needs larger modification than expected.
