From: Li Yu <raise.sail@gmail.com>
Subject: [Question] the precondition of calling alloc_skb()/kfree_skb()?
Date: Fri, 24 Aug 2007 16:58:42 +0800
Message-ID: <46CE9DC2.8070407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:47476 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761020AbXHXI7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 04:59:16 -0400
Received: by rv-out-0910.google.com with SMTP id k20so602385rvb
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 01:59:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, all:

I encountered a problem of using sk_buff.

I used 2.4.20 kernel, when burst traffic come, the kernel will complain
a bug report at skbuff.c:316 later:

311 void __kfree_skb(struct sk_buff *skb)
312 {
313 if (skb->list) {
314 printk(KERN_WARNING "Warning: kfree_skb passed an skb still "
315 "on a list (from %p).\n", NET_CALLER(skb));
316 BUG(); /* HERE!!! */
317 }
/* snip some code here */
332 }


I saw the dev_kfree_skb_irq() and dev_kfree_skb_irq(), and how to use
them. even, in fact, we work in pure poll I/O model, so the NIC can not
issue any interrupt.

And, I searched google, there are many similar reports like above, but
almost of them have no reply. I think there may have some unknown thing
while sk_buff API.

Well, I hope know, are there some preconditions of calling alloc_skb()
or *_kfree_skb_*() ? Thank in advanced.

Good luck.

- Yu Li

