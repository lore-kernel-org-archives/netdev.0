From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Thu, 22 Jul 2010 22:44:50 -0700 (PDT)
Message-ID: <20100722.224450.04662931.davem@davemloft.net>
References: <20100722.102251.165153819.davem@davemloft.net>
	<20100722.102637.201684445.davem@davemloft.net>
	<201007230022.o6N0MKLt053955@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007230022.o6N0MKLt053955@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 23 Jul 2010 09:22:20 +0900

> David Miller wrote:
>> The fact is going to remain that you will be unable to return data
>> from recvmsg() to a blocking socket when ->poll() returns true even
>> though data is in fact there in the socket receive queue.
>> 
>> This is something that the existing LSM hooks do not do.
> 
> This is something that the existing security_socket_recvmsg() hook does do.
> SELinux is unable to return data from recvmsg() to a blocking socket when
> ->poll() returns true even though data is in fact there in the socket receive
> queue.
> We agreed below situation, didn't we?

Existing LSM hook returns an error early, as if the user passed in
incorrect parameters or similar.

It's completely stateless and dependent upon purely the labels
associated with state visible on recvmsg() entry, and independent
of other things such as attributes in the packets contained in
the socket's receive queue.
