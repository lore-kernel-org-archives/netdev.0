From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 02 Aug 2011 04:18:57 -0700 (PDT)
Message-ID: <20110802.041857.1325765319466840715.davem@davemloft.net>
References: <201107280336.p6S3aUY7004372@www262.sakura.ne.jp>
	<20110801.230731.1942061135621106602.davem@davemloft.net>
	<201108020928.p729Sekl091800@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@parisplace.org, anton@samba.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab1HBLTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 07:19:24 -0400
In-Reply-To: <201108020928.p729Sekl091800@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Tue, 02 Aug 2011 18:28:40 +0900

> I think this behavior is not preferable.  In this case, should
> security_socket_sendmsg() return -EAGAIN rather than -EPERM?  Or,
> should sendmmsg() not record errors after some of datagrams were
> sent?

I think you must return -EAGAIN so that the user can see how many
of the datagrams were sent successfully.

In fact, it is a requirement.  What if the sent datagrams have
side effects (f.e. money moves from one bank account to another)?

How else can the application find this out?
