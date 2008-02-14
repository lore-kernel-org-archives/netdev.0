From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][KEY] fix bug in spdadd
Date: Fri, 15 Feb 2008 01:54:05 +1100 (EST)
Message-ID: <20080215.015405.121725938.yoshfuji@linux-ipv6.org>
References: <47B42C3C.5090104@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kazunori@miyazawa.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46164 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbYBNOxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 09:53:23 -0500
In-Reply-To: <47B42C3C.5090104@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47B42C3C.5090104@miyazawa.org> (at Thu, 14 Feb 2008 20:55:40 +0900), Kazunori MIYAZAWA <kazunori@miyazawa.org> says:

> This patch fix a BUG when adding spds which have
> same selector.
> 
> Signed-off-by: Kazunori MIYAZAWA <kazunori@miyazawa.org>

I think we need to fix xfrm_user side as well.

---
[PATCH] [XFRM]: Avoid bogus BUG() when throwing new policy away.

When we destory a new policy entry, we need to tell
xfrm_policy_destroy() explicitly that the entry is not
alive yet.

--- 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 7833807..f971ca5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1105,6 +1105,7 @@ static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p,
 	return xp;
  error:
 	*errp = err;
+	xp->dead = 1;
 	xfrm_policy_destroy(xp);
 	return NULL;
 }

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
