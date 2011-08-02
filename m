From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 02 Aug 2011 04:26:41 -0700 (PDT)
Message-ID: <20110802.042641.2122529993066553943.davem@davemloft.net>
References: <20110801.230731.1942061135621106602.davem@davemloft.net>
	<201108020928.p729Sekl091800@www262.sakura.ne.jp>
	<20110802.041857.1325765319466840715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@parisplace.org, anton@samba.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110802.041857.1325765319466840715.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 02 Aug 2011 04:18:57 -0700 (PDT)

> From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Date: Tue, 02 Aug 2011 18:28:40 +0900
> 
>> I think this behavior is not preferable.  In this case, should
>> security_socket_sendmsg() return -EAGAIN rather than -EPERM?  Or,
>> should sendmmsg() not record errors after some of datagrams were
>> sent?
> 
> I think you must return -EAGAIN so that the user can see how many
> of the datagrams were sent successfully.
> 
> In fact, it is a requirement.  What if the sent datagrams have
> side effects (f.e. money moves from one bank account to another)?
> 
> How else can the application find this out?

Actually, I change my mind. :-)

I think sendmmsg() needs to unconditionally not report an error if any
datagrams were sent successfully.
