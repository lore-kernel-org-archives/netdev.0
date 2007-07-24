From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: Re: Oops in xfrm_bundle_ok
Date: Wed, 25 Jul 2007 00:51:14 +0900 (JST)
Message-ID: <20070725.005114.74734738.chamas@h4.dion.ne.jp>
References: <20070705.024710.74752219.chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm05mta.dion.ne.jp ([219.125.112.3]:1068 "HELO
	nm05omta053.dion.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750854AbXGXPvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 11:51:20 -0400
In-Reply-To: <20070705.024710.74752219.chamas@h4.dion.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello,

From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: Oops in xfrm_bundle_ok
Date: Thu, 05 Jul 2007 02:47:10 +0900 (JST)

> I got Oops like below. I glanced xfrm_bundle_ok() in
> xfrm_policy.c and __xfrm4.bundle_create() in xfrm4_policy.c.

It seems this was fixed by below, thanks a lot.

> commit bd0bf0765ea1fba80d7085e1f0375ec045631dc1
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Jul 18 01:55:52 2007 -0700
>
>     [XFRM]: Fix crash introduced by struct dst_entry reordering
....

@@ -2141,7 +2141,7 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 		if (last == first)
 			break;
 
-		last = last->u.next;
+		last = (struct xfrm_dst *)last->u.dst.next;
 		last->child_mtu_cached = mtu;
 	}
