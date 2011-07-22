From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Question regarding sendmmsg().
Date: Fri, 22 Jul 2011 20:41:20 +0900
Message-ID: <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
References: <201107110304.p6B34422036886@www262.sakura.ne.jp>
	<201107191754.22391.paul.moore@hp.com>
	<201107200142.p6K1gKYg077046@www262.sakura.ne.jp>
	<201107211721.14511.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107211721.14511.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TOMOYO was about to add support for permission checks for
PF_INET/PF_INET6/PF_UNIX socket's bind()/listen()/connect()/send() operations
( http://www.spinics.net/linux/fedora/linux-security-module/msg11496.html ).

According to http://ozlabs.org/~anton/junkcode/sendmmsg_test.c , the sendmmsg()
introduced by commit 228e548e "net: Add sendmmsg socket system call" is capable
of sending to multiple different destinations with single sendmmsg(), isn't it?

If yes, my plan (restricting sendmsg() based on destination's address) became
impossible since security_socket_sendmsg() (which receives the destination's
address) is called for only once even if there are multiple different
destinations.
