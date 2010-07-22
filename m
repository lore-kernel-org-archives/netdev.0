From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Thu, 22 Jul 2010 10:22:51 -0700 (PDT)
Message-ID: <20100722.102251.165153819.davem@davemloft.net>
References: <201007220502.o6M52GJU098071@www262.sakura.ne.jp>
	<20100721.220611.267376790.davem@davemloft.net>
	<201007222146.FGC09386.OFOtFQOVFMJSLH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007222146.FGC09386.OFOtFQOVFMJSLH@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 22 Jul 2010 21:46:55 +0900

> David Miller wrote:
>> > Then, why does below proposal lose information?
>> 
>> Peek changes state, now it's possible that two processes end up
>> receiving the packet.
> 
> Indeed. We will need to protect sock->ops->recvmsg() call using a lock like

But this doesn't matter.

The fact is going to remain that you will be unable to return data
from recvmsg() to a blocking socket when ->poll() returns true even
though data is in fact there in the socket receive queue.

This is something that the existing LSM hooks do not do.

You can't create this silly situation where some packets in the socket
receive queue can be recvmsg()'d by some processes, but not by others.

At best, it is pure crazyness.
