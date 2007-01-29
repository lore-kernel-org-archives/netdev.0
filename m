From: lyw <lyw@nanjing-fnst.com>
Subject: Re:[patch]IPv6:fix BUG of ndisc_send_redirect()
Date: Mon, 29 Jan 2007 18:16:36 +0800
Message-ID: <1170065796.3162.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:48279 "EHLO proxy.fnst.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752489AbXA2KDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 05:03:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mr David:

   I have submitted a patch to fix the ndisc_send_resirect(), and this
patch has been agreed by Mr yoshifuji. But you have not applied yet.
The following is Mr yoshifuji's reply, and I submitted the patch again.


In article <1168679560.3639.11.camel@localhost.localdomain> (at Sat, 13
Jan 2007 17:12:40 +0800), Li Yewang <lyw@nanjing-fnst.com> says:

> >   When I tested IPv6 redirect function about kernel 2.6.19.1, and
found
> > that the kernel can send redirect packets whose target address is
global
> > address, and the target is not the actual endpoint of communication.
:
> > So, I think the send redirect function must check the target address
> > also.

It is not mandatory, however, it is better to do this.  I agree.
(Note: In usual, we do not install gateway'ed route with global
next-hop.)

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji


Following is my patch:

signed-off-by: Li Yewang <lyw@nanjing-fnst.com>
--- a/net/ipv6/ndisc.c  2007-01-29 18:12:35.036415512 +0800
+++ b/net/ipv6/ndisc.c  2007-01-13 17:02:02.000000000 +0800
@@ -1412,6 +1412,13 @@ void ndisc_send_redirect(struct sk_buff
                return;
        }

+       if (!ipv6_addr_equal(&skb->nh.ipv6h->daddr, target) &&
+           !(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
+               ND_PRINTK2(KERN_WARNING
+                       "ICMPv6 Redirect: target address is not link-
local.\n");
+               return;
+       }
+
        ndisc_flow_init(&fl, NDISC_REDIRECT, &saddr_buf, &skb->nh.ipv6h-
>saddr,
                        dev->ifindex);

 

 



