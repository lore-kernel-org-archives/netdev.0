From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: net tree build warning
Date: Thu, 21 May 2009 23:30:38 -0700 (PDT)
Message-ID: <20090521.233038.195647453.davem@davemloft.net>
References: <20090522151642.e79e22ee.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090522151642.e79e22ee.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 22 May 2009 15:16:42 +1000

> Hi Dave,
> 
> Today's linux-next build (powerpc ppc64_defconfig) produced this warning:
> 
> net/core/netpoll.c: In function 'poll_one_napi':
> net/core/netpoll.c:141: warning: passing argument 1 of 'trace_napi_poll' from incompatible pointer type
> include/trace/napi.h:7: note: expected 'struct napi_struct *' but argument is of type 'struct net_device *'
> 
> Introduced by commit 4ea7e38696c7e798c47ebbecadfd392f23f814f9 ("dropmon:
> add ability to detect when hardware dropsrxpackets").

I just pushed the following to fix this:

net: Fix arg to trace_napi_poll() in netpoll.

Reproted by Stephen Rothwell.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/netpoll.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 00b14e2..67b4f3e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -138,7 +138,7 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
 	work = napi->poll(napi, budget);
-	trace_napi_poll(napi->dev);
+	trace_napi_poll(napi);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
 	atomic_dec(&trapped);
-- 
1.6.3
