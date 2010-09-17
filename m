From: Ollie Wild <aaw@google.com>
Subject: Re: [PATCH] Move "struct net" declaration inside the __KERNEL__ macro guard
Date: Fri, 17 Sep 2010 14:38:59 -0500
Message-ID: <AANLkTimRSjqewc_mC5vwdXy1t4Ax5rAf5svpOTbUEF7o@mail.gmail.com>
References: <AANLkTimXnjnkNgwtEVpXKYMxXgmBdye=Gtjeggd4N9UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	David Marmaros <davem@google.com>
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimXnjnkNgwtEVpXKYMxXgmBdye=Gtjeggd4N9UA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Resending with a proper signoff.)

This patch reduces namespace pollution by moving the "struct net" declaration
out of the userspace-facing portion of linux/netlink.h.  It has no impact on
the kernel, and the declaration is not referenced anywhere outside the
__KERNEL__ macro guard.

(This came up because we have several C++ applications which use "net" as a
namespace name.)

Ollie

Signed-off-by: Ollie Wild <aaw@google.com>

---
 include/linux/netlink.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 59d0669..1235669 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -27,8 +27,6 @@

 #define MAX_LINKS 32

-struct net;
-
 struct sockaddr_nl {
      sa_family_t     nl_family;      /* AF_NETLINK   */
      unsigned short  nl_pad;         /* zero         */
@@ -151,6 +149,8 @@ struct nlattr {
 #include <linux/capability.h>
 #include <linux/skbuff.h>

+struct net;
+
 static inline struct nlmsghdr *nlmsg_hdr(const struct sk_buff *skb)
 {
      return (struct nlmsghdr *)skb->data;
--
1.7.0.4
