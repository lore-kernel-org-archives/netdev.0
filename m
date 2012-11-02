From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] net-ipv6: change %8s to %s for rt->dst.dev->name in seq_printf
 of rt6_info_route
Date: Fri, 02 Nov 2012 16:55:01 +0800
Message-ID: <50938A65.6040507@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:18015 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757555Ab2KBIyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 04:54:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric Dumazet:

1) This time (the first time):
   A) I have done according to what you have suggested.
      i)   git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
      ii)  format with `git format-patch -s --summary --stat`
      iii) cc to netdev@vger.kernel.org (not to linux-kernle@vger.kernel.org)  
   B) please check the 'Main Contents' (below of this mail).
   C) thank you for your original information again, they are truly useful for me.

2) Next time (if also for net/ipv6):
   A) I will send mail according to MAINTAINERS (which also you suggested)
      M:      "David S. Miller" <davem@davemloft.net>
      M:      Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
      M:      James Morris <jmorris@namei.org>
      M:      Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
      M:      Patrick McHardy <kaber@trash.net>
      L:      netdev@vger.kernel.org
      T:      git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
   B) Only have 'Main Content' in next time.


Main Contents:
-----------------------------------------------------------------------------------
From: Chen Gang <gang.chen@asianux.com>
Date: Fri, 2 Nov 2012 16:02:11 +0800
Subject: [PATCH] net-ipv6: change %8s to %s for rt->dst.dev->name in seq_printf of rt6_info_route

  the length of rt->dst.dev->name is 16 (IFNAMSIZ)
  in seq_printf, it is not suitable to use %8s for rt->dst.dev->name.
  so change it to %s, since each line has not been solid any more.

  additional information:

    %8s  limit the width, not for the original string output length
         if name length is more than 8, it still can be fully displayed.
         if name length is less than 8, the ' ' will be filled before name.

    %.8s truly limit the original string output length (precision)


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/ipv6/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c42650c..b60bc52 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2835,7 +2835,7 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
        } else {
                seq_puts(m, "00000000000000000000000000000000");
        }
-       seq_printf(m, " %08x %08x %08x %08x %8s\n",
+       seq_printf(m, " %08x %08x %08x %08x %s\n",
                   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
                   rt->dst.__use, rt->rt6i_flags,
                   rt->dst.dev ? rt->dst.dev->name : "");
-- 
1.7.9.5




-- 
Chen Gang

Asianux Corporation
