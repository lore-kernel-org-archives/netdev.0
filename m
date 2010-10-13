From: David Miller <davem@davemloft.net>
Subject: Re: [-next Oct 13] Build failure drivers/s390/net/ctcm_mpc.o
Date: Wed, 13 Oct 2010 09:12:58 -0700 (PDT)
Message-ID: <20101013.091258.193716224.davem@davemloft.net>
References: <4CB5CB9C.9030603@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com,
	eric.dumazet@gmail.com
To: sachinp@in.ibm.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4CB5CB9C.9030603@in.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sachin Sant <sachinp@in.ibm.com>
Date: Wed, 13 Oct 2010 20:39:16 +0530

> Today's next fails to build on a s390 box with following
> error
> 
> drivers/s390/net/ctcm_mpc.c: In function ctc_mpc_dealloc_ch:
> drivers/s390/net/ctcm_mpc.c:541: error: struct net_device has no
> member named refcnt

This should fix it:

--------------------
s390: ctcm_mpc: Fix build after netdev refcount changes.

Reported-by: Sachin Sant <sachinp@in.ibm.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/s390/net/ctcm_mpc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/s390/net/ctcm_mpc.c b/drivers/s390/net/ctcm_mpc.c
index 2861e78..b64881f 100644
--- a/drivers/s390/net/ctcm_mpc.c
+++ b/drivers/s390/net/ctcm_mpc.c
@@ -540,7 +540,7 @@ void ctc_mpc_dealloc_ch(int port_num)
 
 	CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_DEBUG,
 			"%s: %s: refcount = %d\n",
-			CTCM_FUNTAIL, dev->name, atomic_read(&dev->refcnt));
+			CTCM_FUNTAIL, dev->name, netdev_refcnt_read(dev));
 
 	fsm_deltimer(&priv->restart_timer);
 	grp->channels_terminating = 0;
-- 
1.7.3.1
