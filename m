From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] xfrm6: remove unneeded NULL check in __xfrm6_output()
Date: Wed, 1 Feb 2012 10:45:26 +0300
Message-ID: <20120201074526.GC22179@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:51875 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293Ab2BAHqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 02:46:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't check for NULL consistently in __xfrm6_output().  If "x" were
NULL here it would lead to an OOPs later.  I asked Steffen Klassert
about this and he suggested that we remove the NULL check.

On 10/29/11, Steffen Klassert <steffen.klassert@secunet.com> wrote:
>> net/ipv6/xfrm6_output.c
>>    148	
>>    149		if ((x && x->props.mode == XFRM_MODE_TUNNEL) &&
>>                           ^
>
> x can't be null here. It would be a bug if __xfrm6_output() is called
> without a xfrm_state attached to the skb. I think we can just remove
> this null check.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 4eeff89..8755a30 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -146,7 +146,7 @@ static int __xfrm6_output(struct sk_buff *skb)
 		return -EMSGSIZE;
 	}
 
-	if ((x && x->props.mode == XFRM_MODE_TUNNEL) &&
+	if (x->props.mode == XFRM_MODE_TUNNEL &&
 	    ((skb->len > mtu && !skb_is_gso(skb)) ||
 		dst_allfrag(skb_dst(skb)))) {
 			return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
