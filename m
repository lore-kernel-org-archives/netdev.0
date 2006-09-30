From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [IPROUTE2][PATCH] Add missing macros which was removed from kernel header. (Re: [GIT PATCH] NET: Fixes for net-2.6.19)
Date: Sat, 30 Sep 2006 16:27:07 +0900
Message-ID: <200609301627.08278.nakam@linux-ipv6.org>
References: <20060928155052.63ed5ce8@freekitty> <20060928.172827.26929236.davem@davemloft.net> <451C7E11.6040506@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	tgraf@suug.ch, netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:8671 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751077AbWI3H1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 03:27:13 -0400
To: shemminger@osdl.org
In-Reply-To: <451C7E11.6040506@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> David Miller wrote:
> >> commit 0844565fb8a9418f5a860aa480c1aef70319c9a2
> >> Author: Thomas Graf <tgraf@suug.ch>
> >> Date:   Fri Aug 4 23:05:56 2006 -0700
> >>
> >>     [NET]: Move netlink interface bits to linux/if.h
> >>     
> >>     Signed-off-by: Thomas Graf <tgraf@suug.ch>
> >>     Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > Stephen, we just removed the troublesome bits from linux/if.h when I
> > put in Yoshifuji's patches last night, it should explicitly remove
> > this problem.
> > 
> > You will thus see that linux/rtnetlink.h no longer includes
> > linux/if.h, which is why your errors were completely perplexing
> > to me.  Instead, it includes linux/if_link.h
> > 
> > It's been in my tree since last night, and if you had used
> > the rtnetlink.h from my current tree you wouldn't have seen
> > the error.
> 
> Yes, as David mentioned you need to copy the latest rtnetlink.h
> at first. It is also required to be added if_{link,addr}.h, neighbour.h
> to iproute2 tree. Some macros may be needed for libnetlink.h, too.
> I'll send the patch to you if you haven't started on it.

Stephen, this patch is for iproute2. Please check and apply it after syncing
kernel headers (e.g. rtnetlink.h) with David's tree. Please also note to add
new ones (i.e. include/linux/{if_link.h,if_addr.h,neighbour.h}) which is
split from rtnetlink.h.


[PATCH] Add missing macros which was removed from kernel header.

{IFA,IFLA,NDA,NDTA}_{RTA,PAYLOAD} macro is removed from kernel
header since net-2.6.19 because it is not used by kernel code.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/libnetlink.h |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 63cc3c8..9de3a0b 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -4,6 +4,9 @@ #define __LIBNETLINK_H__ 1
 #include <asm/types.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
+#include <linux/if_link.h>
+#include <linux/if_addr.h>
+#include <linux/neighbour.h>
 
 struct rtnl_handle
 {
@@ -53,5 +56,37 @@ extern int rtnl_from_file(FILE *, rtnl_f
 #define NLMSG_TAIL(nmsg) \
 	((struct rtattr *) (((void *) (nmsg)) + NLMSG_ALIGN((nmsg)->nlmsg_len)))
 
+#ifndef IFA_RTA
+#define IFA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
+#endif
+#ifndef IFA_PAYLOAD
+#define IFA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
+#endif
+
+#ifndef IFLA_RTA
+#define IFLA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
+#endif
+#ifndef IFLA_PAYLOAD
+#define IFLA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
+#endif
+
+#ifndef NDA_RTA
+#define NDA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndmsg))))
+#endif
+#ifndef NDA_PAYLOAD
+#define NDA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ndmsg))
+#endif
+
+#ifndef NDTA_RTA
+#define NDTA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndtmsg))))
+#endif
+#ifndef NDTA_PAYLOAD
+#define NDTA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndtmsg))
+#endif
+
 #endif /* __LIBNETLINK_H__ */
 
-- 
1.4.2




-- 
Masahide NAKAMURA
