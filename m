From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Fri, 23 Jul 2010 00:29:13 -0700 (PDT)
Message-ID: <20100723.002913.264776153.davem@davemloft.net>
References: <201007230022.o6N0MKLt053955@www262.sakura.ne.jp>
	<20100722.224450.04662931.davem@davemloft.net>
	<201007230721.o6N7Lc2L048186@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007230721.o6N7Lc2L048186@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 23 Jul 2010 16:21:38 +0900

> Users calling recvmsg() after select() said "read operation will return with
> available data without blocking as long as you pass correct parameters" will
> get error code even if they passed correct parameters.

This is nonsense, because not all "parameters" are not visible to poll().

These "parameters" I speak of are virtual, they are my way of saying
that the errors returned by the existing LSM hooks are more like -EFAULT
or -EACCESS than -EINTR/-EAGAIN or blocking, the latter of which are
what are illegal for blocking socket invoking recvmsg() after poll
indicates there is data to read.
