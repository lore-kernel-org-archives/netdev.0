From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Tue, 27 Apr 2010 10:18:04 -0700 (PDT)
Message-ID: <20100427.101804.13765995.davem@davemloft.net>
References: <20100427152516.580ee620.sfr@canb.auug.org.au>
	<20100427.093430.258110898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100427.093430.258110898.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 27 Apr 2010 09:34:30 -0700 (PDT)

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 27 Apr 2010 15:25:16 +1000
> 
>> After merging the bkl-ioctl tree, today's linux-next build (powerpc
>> ppc44x_defconfig) failed like this:
>> 
>> net/bridge/br_multicast.c: In function 'br_ip6_multicast_alloc_query':
>> net/bridge/br_multicast.c:469: error: implicit declaration of function 'csum_ipv6_magic'
>> 
>> Introduced by commit 08b202b6726459626c73ecfa08fcdc8c3efc76c2 ("bridge
>> br_multicast: IPv6 MLD support") from the net tree.
>> 
>> csum_ipv6_magic is declared in net/ip6_checksum.h ...
> 
> Bummer, powerpc is one of the few platforms that doesn't get the header
> file implicitly so you always trip over this whereas we never see it in
> x86 and sparc64 builds :-)
> 
> I'll fix this, thanks!

I just committed the following for this:

bridge: Fix build of ipv6 multicast code.

Based upon a report from Stephen Rothwell:

--------------------
net/bridge/br_multicast.c: In function 'br_ip6_multicast_alloc_query':
net/bridge/br_multicast.c:469: error: implicit declaration of function 'csum_ipv6_magic'

Introduced by commit 08b202b6726459626c73ecfa08fcdc8c3efc76c2 ("bridge
br_multicast: IPv6 MLD support") from the net tree.

csum_ipv6_magic is declared in net/ip6_checksum.h ...
--------------------

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bridge/br_multicast.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index e481dbd..2048ef0 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -28,6 +28,7 @@
 #include <net/ipv6.h>
 #include <net/mld.h>
 #include <net/addrconf.h>
+#include <net/ip6_checksum.h>
 #endif
 
 #include "br_private.h"
-- 
1.7.0.4
