From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Mon, 20 Sep 2004 15:20:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920.152012.114156249.yoshfuji@linux-ipv6.org>
References: <20040919074605.GJ6005@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.44.0409200806460.22679-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, davem@davemloft.net, netdev@oss.sgi.com,
        usagi-users@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi, davem@davemloft.net
In-Reply-To: <Pine.LNX.4.44.0409200806460.22679-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0409200806460.22679-100000@netcore.fi> (at Mon, 20 Sep 2004 08:08:36 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> On Sun, 19 Sep 2004, Harald Welte wrote:
> > Apparently this happens when you 
> > 
> > 1) insmod ipv6
> > 2) ifconfig your interfaces up
> > 3) only now ifconfig 'lo' up.
> > 
> > This happened due to a typo in my script :(  If 'lo' exists prior to the
> > other interfaces, everything seems to work as usual.
> > 
> > Is this desired or accidential and/or documented behaviour?
> 
> AFAIK, it's not documented, but known among developers (in general): 
> there's a lot of magic tied to the loopback interface, and lots of 
> things (like ND) break very badly if it's not always up and running 
> appropriately..

I agree that it is not documented.

This behavior lives for years (AFAIK),
and we haven't got so many reports 
because people usually bring loopback device first.

I think the following message will help people, anyway.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/route.c 1.94 vs edited =====
--- 1.94/net/ipv6/route.c	2004-09-15 06:03:30 +09:00
+++ edited/net/ipv6/route.c	2004-09-20 14:59:08 +09:00
@@ -1373,6 +1373,12 @@
 	if (rt == NULL)
 		return ERR_PTR(-ENOMEM);
 
+	if (!(loopback_dev.flags & IFF_UP)) {
+		printk(KERN_WARNING "INET6: please bring loopback device up"
+				    "first.\n");
+		return ERR_PTR(-ENETDOWN);
+	}
+
 	dev_hold(&loopback_dev);
 	in6_dev_hold(idev);
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
