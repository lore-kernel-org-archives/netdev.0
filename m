From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Wed, 27 Jul 2016 08:20:57 +0200
Message-ID: <579852C9.1020505@oracle.com>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
 <578F6628.4010002@oracle.com> <20160727030117.GA23226@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070202080500040904090300"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18908 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbcG0GVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 02:21:13 -0400
In-Reply-To: <20160727030117.GA23226@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070202080500040904090300
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 07/27/2016 05:01 AM, Herbert Xu wrote:
> On Wed, Jul 20, 2016 at 01:53:12PM +0200, Vegard Nossum wrote:
>> Just FYI I'm also running into the
>>
>> // reset the timers here?
>> WARN(1, "Don't know what to do with soft policy expire\n");
>>
>> in xfrm_add_pol_expire() from the same commit, but that looks
>> potentially somewhat more serious (or at least it looks like we might
>> want to do some sort of cleaning up), so I won't touch it for now.
>
> It certainly shouldn't be a WARN, it probably shouldn't print
> anything either.

Here's another patch to remove that too.

I don't actually *use* this code myself and I feel the justification
I've given for removing the WARN to be a bit weak, so if you don't take
the patch I'll just keep it in my local tree to keep it from showing up
again during fuzzing.

Thanks,


Vegard

--------------070202080500040904090300
Content-Type: text/x-patch;
 name="0001-xfrm-get-rid-of-another-incorrect-WARN.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-xfrm-get-rid-of-another-incorrect-WARN.patch"

>From 5b302eb4c188064a69176a901c2bec3e19440c03 Mon Sep 17 00:00:00 2001
From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Wed, 27 Jul 2016 08:13:14 +0200
Subject: [PATCH] xfrm: get rid of another incorrect WARN

During fuzzing I regularly run into this WARN(). According to Herbert Xu,
this "certainly shouldn't be a WARN, it probably shouldn't print anything
either".

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/xfrm/xfrm_user.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2477b24..a4e44f7 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2053,7 +2053,6 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		xfrm_audit_policy_delete(xp, 1, true);
 	} else {
 		// reset the timers here?
-		WARN(1, "Don't know what to do with soft policy expire\n");
 	}
 	km_policy_expired(xp, p->dir, up->hard, nlh->nlmsg_pid);
 
-- 
1.9.1


--------------070202080500040904090300--
