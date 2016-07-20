From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Wed, 20 Jul 2016 13:53:12 +0200
Message-ID: <578F6628.4010002@oracle.com>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28641 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbcGTLx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 07:53:29 -0400
In-Reply-To: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2016 10:32 AM, Vegard Nossum wrote:
> AFAICT this message is just printed whenever input validation fails.
> This is a normal failure and we shouldn't be dumping the stack over it.
>
> Looks like it was originally a printk that was maybe incorrectly
> upgraded to a WARN:
>
> commit 62db5cfd70b1ef53aa21f144a806fe3b78c84fab
> Author: stephen hemminger <shemminger@vyatta.com>
> Date:   Wed May 12 06:37:06 2010 +0000
>
>      xfrm: add severity to printk

Just FYI I'm also running into the

// reset the timers here?
WARN(1, "Don't know what to do with soft policy expire\n");

in xfrm_add_pol_expire() from the same commit, but that looks
potentially somewhat more serious (or at least it looks like we might
want to do some sort of cleaning up), so I won't touch it for now.

Added some more XFRM people to Cc.


Vegard

 > Cc: Stephen Hemminger <stephen@networkplumber.org>
 > Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
 > ---
 >   net/xfrm/xfrm_user.c | 2 +-
 >   1 file changed, 1 insertion(+), 1 deletion(-)
 >
 > diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
 > index 4fb04ce..0b81bfc 100644
 > --- a/net/xfrm/xfrm_user.c
 > +++ b/net/xfrm/xfrm_user.c
 > @@ -2150,7 +2150,7 @@ static int xfrm_add_acquire(struct sk_buff 
*skb, struct nlmsghdr *nlh,
 >   	return 0;
 >
 >   bad_policy:
 > -	WARN(1, "BAD policy passed\n");
 > +	printk(KERN_WARNING "xfrm_user: bad policy passed\n");
 >   free_state:
 >   	kfree(x);
 >   nomem:
 >
