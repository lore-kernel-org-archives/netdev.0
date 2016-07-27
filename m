From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Wed, 27 Jul 2016 08:44:15 +0200
Message-ID: <5798583F.6060404@oracle.com>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
 <578F6628.4010002@oracle.com> <20160727030117.GA23226@gondor.apana.org.au>
 <579852C9.1020505@oracle.com> <20160727063127.GA24473@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040304030601060205050603"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26974 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbcG0Goc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 02:44:32 -0400
In-Reply-To: <20160727063127.GA24473@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040304030601060205050603
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 07/27/2016 08:31 AM, Herbert Xu wrote:
> On Wed, Jul 27, 2016 at 08:20:57AM +0200, Vegard Nossum wrote:
>>
>> Here's another patch to remove that too.
>>
>> I don't actually *use* this code myself and I feel the justification
>> I've given for removing the WARN to be a bit weak, so if you don't take
>> the patch I'll just keep it in my local tree to keep it from showing up
>> again during fuzzing.
>
> Please just kill the whole else clause.  For soft policy expires
> we simply need to relay a message to the KM and nothing more.

Try #2 :-)


Vegard

--------------040304030601060205050603
Content-Type: text/x-patch;
 name="0001-xfrm-get-rid-of-another-incorrect-WARN.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-xfrm-get-rid-of-another-incorrect-WARN.patch"

>From e5111e4dcd0e0c0990d3f4bba0ba0bc9d0b40bae Mon Sep 17 00:00:00 2001
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
 net/xfrm/xfrm_user.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2477b24..10e4e26 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2051,9 +2051,6 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (up->hard) {
 		xfrm_policy_delete(xp, p->dir);
 		xfrm_audit_policy_delete(xp, 1, true);
-	} else {
-		// reset the timers here?
-		WARN(1, "Don't know what to do with soft policy expire\n");
 	}
 	km_policy_expired(xp, p->dir, up->hard, nlh->nlmsg_pid);
 
-- 
1.9.1


--------------040304030601060205050603--
