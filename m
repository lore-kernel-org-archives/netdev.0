From: Li Yewang <lyw@nanjing-fnst.com>
Subject: Re:[PATCH]Fix BUG of ip_rt_send_redirect()
Date: Tue, 19 Dec 2006 09:45:25 +0800
Message-ID: <1166492725.3180.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:59544 "EHLO proxy.fnst.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932643AbWLSB7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 20:59:42 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> Applied, but I had to fix many errors in your patch by hand.
> Please take care of these details next time.
> 
> Here, your email client wrapped the lines in the patch, corrupting it.
> 
> Please use real tab characters, when necessary, in the indentation of
> new code lines that you add, not just spaces.
> 
> Thank you.

Mr David Miller

I have made another patch file about the ip_rt_send_redirect().
This patch has not wrapped lines, and can be patched into the kernel.

Following is my patch:

signed-off-by: Li Yewang <lyw@nanjing-fnst.com>

--- a/net/ipv4/route.org.c	2006-12-19 09:22:16.260271000 +0800
+++ a/net/ipv4/route.c	2006-12-19 09:22:16.241273888 +0800
@@ -1327,7 +1327,8 @@ void ip_rt_send_redirect(struct sk_buff 
 	/* Check for load limit; set rate_last to the latest sent
 	 * redirect.
 	 */
-	if (time_after(jiffies,
+	if (rt->u.dst.rate_tokens == 0 ||
+	    time_after(jiffies,
 		       (rt->u.dst.rate_last +
 			(ip_rt_redirect_load << rt->u.dst.rate_tokens)))) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);


