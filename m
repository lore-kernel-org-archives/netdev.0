From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6 addrconf: Ignore requests to set NODAD flag when
 changing addresses
Date: Thu, 05 Jun 2008 11:53:14 +0900 (JST)
Message-ID: <20080605.115314.80065467.yoshfuji@linux-ipv6.org>
References: <20080604234751.GH20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@ml.linux-ipv6.org,
	nakam@gomagoma.org, takamiya@po.ntts.co.jp
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58141 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbYFECwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 22:52:37 -0400
In-Reply-To: <20080604234751.GH20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080604234751.GH20815@postel.suug.ch> (at Thu, 5 Jun 2008 01:47:51 +0200), Thomas Graf <tgraf@suug.ch> says:

> The decision to run DAD has already been made at the time the address
> was added. Changing the flag later on does not have any effect and
> is only confusing.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I need let MIP team check this but anyway....

If the NODAD flag change is confusing, just clear
that flag in the caller.

And well, it does not take effect so far, but 
DAD after link failure logic is planned in long term.
So current code is okay to me.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3a83557..05dcfd8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3191,7 +3191,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 		prefered_lft = 0x7FFFFFFF/HZ;
 
 	spin_lock_bh(&ifp->lock);
-	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
+	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_HOMEADDRESS)) | ifa_flags;
 	ifp->tstamp = jiffies;
 	ifp->valid_lft = valid_lft;
 	ifp->prefered_lft = prefered_lft;
@@ -3245,7 +3245,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		return -ENODEV;
 
 	/* We ignore other flags so far. */
-	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
+	ifa_flags = ifm->ifa_flags & IFA_F_HOMEADDRESS;
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {

--yoshfuji
