From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [NET] 2.6.x build warning
Date: Fri, 27 May 2005 09:54:26 +0900 (JST)
Message-ID: <20050527.095426.115036280.yoshfuji@linux-ipv6.org>
References: <42961EDB.7000407@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@pobox.com
In-Reply-To: <42961EDB.7000407@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <42961EDB.7000407@pobox.com> (at Thu, 26 May 2005 15:09:15 -0400), Jeff Garzik <jgarzik@pobox.com> says:

> from current git tree:
> 
> net/ipv6/ip6_flowlabel.c: In function `ipv6_flowlabel_opt':
> net/ipv6/ip6_flowlabel.c:540: warning: ignoring return value of 
> `copy_to_user', declared with attribute warn_unused_result

As before, it is intentional.
Okay, let's just waste the result for avoiding the warning.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Index: net/ipv6/ip6_flowlabel.c
===================================================================
--- 30b3bda5e47d088b46ab8eab4d69d059a71197e1/net/ipv6/ip6_flowlabel.c  (mode:100644)
+++ uncommitted/net/ipv6/ip6_flowlabel.c  (mode:100644)
@@ -535,10 +535,11 @@
 		if (err)
 			goto done;
 
-		/* Do not check for fault */
-		if (!freq.flr_label)
-			copy_to_user(&((struct in6_flowlabel_req __user *) optval)->flr_label,
-				     &fl->label, sizeof(fl->label));
+		if (!freq.flr_label) {
+			/* Do not check for fault */
+			int dummy = copy_to_user(&((struct in6_flowlabel_req __user *) optval)->flr_label,
+						 &fl->label, sizeof(fl->label));
+		}
 
 		sfl1->fl = fl;
 		sfl1->next = np->ipv6_fl_list;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
