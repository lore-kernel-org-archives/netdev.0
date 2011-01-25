From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/20] staging/appletalk: remove the BKL
Date: Tue, 25 Jan 2011 14:29:26 -0800 (PST)
Message-ID: <20110125.142926.246535705.davem@davemloft.net>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de>
	<1295993854-4971-15-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295993854-4971-15-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 25 Jan 2011 23:17:28 +0100

> This changes appletalk to use lock_sock instead of
> lock_kernel for serialization. I tried to make sure
> that we don't hold the socket lock during sleeping
> functions, but I did not try to prove whether the
> locks are necessary in the first place.
> 
> Compile-tested only.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

If you're moving appletalk to staging because "nobody is motivated
enough to remove the BKL" and then you actually do the work to remove
the BKL, I really don't see any point in doing the whole staging
thing.

We always keep an eye on every protocol that sits under the top-level
net/.  Every socket API change propagates, as does every other
networking API change that matters for those protocols.

You can move appletalk down to staging if that stops happening, which
it won't.
