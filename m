From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM] Allow transport SAs even when there is no policy
Date: Tue, 19 Oct 2004 16:16:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417521A2.4010500@trash.net>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net> <20041017231258.GA29294@gondor.apana.org.au> <417428CF.2050802@trash.net> <20041018214326.GA6589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020002090801030001080100"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041018214326.GA6589@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020002090801030001080100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:

>What I meant to say is all packets with tunnel mode SAs should be
>rejected since we don't allow optional tunnel transforms for security
>reasons.
>
>This patch fixes it.
>
Looks good. So you agree we should also apply my patch to
xfrm_policy_lookup (attached again with less confusing subject) ? It makes
packets with a secpath fall through to __xfrm_policy_check when the policy
list is empty, so the default policy is always the same. This will break
setups with keying daemons that don't add forward policies for tunnel mode
SAs.

Regards
Patrick


--------------020002090801030001080100
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/19 16:04:44+02:00 kaber@coreworks.de 
#   [XFRM]: Apply policy checks to packets with a secpath when the policy list is empty
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/xfrm.h
#   2004/10/19 16:04:18+02:00 kaber@coreworks.de +1 -1
#   [XFRM]: Apply policy checks to packets with a secpath when the policy list is empty
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2004-10-19 16:05:39 +02:00
+++ b/include/net/xfrm.h	2004-10-19 16:05:39 +02:00
@@ -601,7 +601,7 @@
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
 		return __xfrm_policy_check(sk, dir, skb, family);
 		
-	return	!xfrm_policy_list[dir] ||
+	return	(!xfrm_policy_list[dir] && !skb->sp) ||
 		(skb->dst->flags & DST_NOPOLICY) ||
 		__xfrm_policy_check(sk, dir, skb, family);
 }

--------------020002090801030001080100--
