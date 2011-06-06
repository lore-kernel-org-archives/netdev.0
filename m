From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for June 6 (sctp)
Date: Mon, 06 Jun 2011 13:06:20 -0700 (PDT)
Message-ID: <20110606.130620.1866725220563870006.davem@davemloft.net>
References: <20110606132036.aebd73a4.sfr@canb.auug.org.au>
	<20110606125532.793b3cfd.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-sctp@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110606125532.793b3cfd.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 6 Jun 2011 12:55:32 -0700

> On Mon, 6 Jun 2011 13:20:36 +1000 Stephen Rothwell wrote:
> 
>> Hi all,
>> 
>> Changes since 20110603:
> 
> 
> when CONFIG_IPV6 is not enabled:
> 
> ERROR: "ipv6_chk_addr" [net/sctp/sctp.ko] undefined!

I'll push the following after some build testing, thanks.

--------------------
sctp: Guard IPV6 specific code properly.

Outside of net/sctp/ipv6.c, IPV6 specific code needs to
be ifdef guarded.

This fixes build failures with IPV6 disabled.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/protocol.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index af0a6b0..ab5ded2 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -637,6 +637,7 @@ void sctp_addr_wq_timeout_handler(unsigned long arg)
 		    " for cmd %d at entry %p\n", &sctp_addr_waitq, &addrw->a, addrw->state,
 		    addrw);
 
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 		/* Now we send an ASCONF for each association */
 		/* Note. we currently don't handle link local IPv6 addressees */
 		if (addrw->a.sa.sa_family == AF_INET6) {
@@ -659,7 +660,7 @@ void sctp_addr_wq_timeout_handler(unsigned long arg)
 				break;
 			}
 		}
-
+#endif
 		list_for_each_entry(sp, &sctp_auto_asconf_splist, auto_asconf_list) {
 			struct sock *sk;
 
-- 
1.7.5.2
