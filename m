From: domen@coderock.org
Subject: [patch 4/5] net/ipv6/ip6_flowlabel.c: copy_to_user return code
Date: Sun, 06 Mar 2005 23:21:17 +0100
Message-ID: <20050306222118.401D11ED3D@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, yrgrknmxpzlk@gawab.com
To: davem@redhat.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


compile warning cleanup - handle copy_to/from_user error 
returns

Signed-off-by: Stephen Biggs <yrgrknmxpzlk@gawab.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/net/ipv6/ip6_flowlabel.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff -puN net/ipv6/ip6_flowlabel.c~return_code-net_ipv6_ip6_flowlabel net/ipv6/ip6_flowlabel.c
--- kj/net/ipv6/ip6_flowlabel.c~return_code-net_ipv6_ip6_flowlabel	2005-03-05 16:13:10.000000000 +0100
+++ kj-domen/net/ipv6/ip6_flowlabel.c	2005-03-05 16:13:10.000000000 +0100
@@ -537,9 +537,13 @@ release:
 			goto done;
 
 		/* Do not check for fault */
-		if (!freq.flr_label)
-			copy_to_user(&((struct in6_flowlabel_req __user *) optval)->flr_label,
-				     &fl->label, sizeof(fl->label));
+		if (!freq.flr_label) {
+			if (copy_to_user(&((struct in6_flowlabel_req __user *)optval)->flr_label,
+				     &fl->label, sizeof(fl->label))) {
+				err = -EFAULT;
+				goto done;
+			}
+		}
 
 		sfl1->fl = fl;
 		sfl1->next = np->ipv6_fl_list;
_
