From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Check against correct policy list in ip_forward/ip6_forward
Date: Mon, 18 Oct 2004 00:42:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4172F53F.2040808@trash.net>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000007000302020204020909"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4172F1AB.4020305@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000007000302020204020909
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:

> Thanks, I didn't know pluto uses the xfrm_user interface, so
> I only looked for pfkey symbolic names. So it seems only racoon
> needs to be fixed. I think we should apply the attached patch
> to make xfrm_policy_check reject packets decapsulated by IPsec
> without a policy for this direction, so people will notice
> something is wrong. It also prevents skipping checks against the
> socket policy if there is an empty policy list .. or am I missing
> something ?

Obsiously I did :) This patch should be better.

> Regards
> Patrick
>
>--- a/include/net/xfrm.h	2004-10-18 00:15:18 +02:00
>+++ b/include/net/xfrm.h	2004-10-18 00:15:18 +02:00
>@@ -601,7 +601,7 @@
> 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
> 		return __xfrm_policy_check(sk, dir, skb, family);
> 		
>-	return	!xfrm_policy_list[dir] ||
>+	return	((!sk || !sk->sk_policy[dir]) && !xfrm_policy_list[dir] && !skb->sp) ||
> 		(skb->dst->flags & DST_NOPOLICY) ||
> 		__xfrm_policy_check(sk, dir, skb, family);
> }
>  
>


--------------000007000302020204020909
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== include/net/xfrm.h 1.68 vs edited =====
--- 1.68/include/net/xfrm.h	2004-09-10 23:35:53 +02:00
+++ edited/include/net/xfrm.h	2004-10-18 00:41:28 +02:00
@@ -601,7 +601,7 @@
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
 		return __xfrm_policy_check(sk, dir, skb, family);
 		
-	return	!xfrm_policy_list[dir] ||
+	return	(!xfrm_policy_list[dir] && !skb->sp) ||
 		(skb->dst->flags & DST_NOPOLICY) ||
 		__xfrm_policy_check(sk, dir, skb, family);
 }

--------------000007000302020204020909--
