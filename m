From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BK PATCH] [IPV6] Multiple locking fixes/improvements
Date: Tue, 23 Nov 2004 13:37:44 -0500 (EST)
Message-ID: <20041123.133744.48357645.yoshfuji@linux-ipv6.org>
References: <20041122.223205.14979415.yoshfuji@linux-ipv6.org>
	<41A37CD4.3030503@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian.Haley@hp.com
In-Reply-To: <41A37CD4.3030503@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <41A37CD4.3030503@hp.com> (at Tue, 23 Nov 2004 13:09:24 -0500), Brian Haley <Brian.Haley@hp.com> says:

> Not to nitpick, but this is just easier to read:
> 
> +static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
> +{
> +	read_lock_bh(&addrconf_lock);
> +	if (!ifp->idev->dead)
> +		__ipv6_ifa_notify(event, ifp);
> +	read_unlock_bh(&addrconf_lock);
>   }

agreed and added one changeset.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/24 03:34:53+09:00 Brian.Haley@hp.com 
#   [IPV6] improve ipv6_ifa_notify() readability.
# 
# net/ipv6/addrconf.c
#   2004/11/24 03:34:41+09:00 Brian.Haley@hp.com +2 -4
#   [IPV6] improve ipv6_ifa_notify() readability.
# 
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-11-24 03:35:33 +09:00
+++ b/net/ipv6/addrconf.c	2004-11-24 03:35:33 +09:00
@@ -3017,10 +3017,8 @@
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
 	read_lock_bh(&addrconf_lock);
-	if (ifp->idev->dead)
-		goto out;
-	__ipv6_ifa_notify(event, ifp);
-out:
+	if (likely(ifp->idev->dead == 0))
+		__ipv6_ifa_notify(event, ifp);
 	read_unlock_bh(&addrconf_lock);
 }
 


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
