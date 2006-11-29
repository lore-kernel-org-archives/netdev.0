From: Li Yewang <lyw@nanjing-fnst.com>
Subject: Re:[PATCH]Fix BUG of ip_rt_send_redirect()
Date: Wed, 29 Nov 2006 16:51:31 +0800
Message-ID: <1164790291.14696.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:46184 "EHLO proxy.fnst.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753312AbWLRF7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 00:59:47 -0500
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:

> 
> Since rate_last can also be zero if jiffies == 0 (OK that's
> extremely unlikely but I'm feeling picky today :), how about
> checking rate_tokens instead? The value of rate_last can only
> be relevant if rate_tokens is non-zero.
> 
> BTW, please also check the other spots where rate_last/rate_token
> is used.  They might need a similar fix.
> 
> Cheers,

Mr Herbert Xu

According to your advice, I have made another patch for the redirect
bug.

I have also checked other spots where rate_last/rate_tokens is used.
Those places need not be fixed.

Following is my patch:

signed-off-by: Li Yewang<lyw@nanjing-fnst.com>

--- linux-2.6.19.1/net/ipv4/route.c     2006-12-12 03:32:54.000000000
+0800
+++ linux-2.6.19.1/net/ipv4/route.org.c 2006-11-29 16:14:34.592058480
+0800
@@ -1327,7 +1327,8 @@ void ip_rt_send_redirect(struct sk_buff
        /* Check for load limit; set rate_last to the latest sent
         * redirect.
         */
-       if (time_after(jiffies,
+       if (rt->u.dst.rate_tokens == 0 ||
+            time_after(jiffies,
                       (rt->u.dst.rate_last +
                        (ip_rt_redirect_load << rt-
>u.dst.rate_tokens)))) {
                icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt-
>rt_gateway);



