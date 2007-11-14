From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Bug in using inet_lookup ()
Date: Wed, 14 Nov 2007 14:13:05 +0300
Message-ID: <20071114111305.GA14670@2ka.mipt.ru>
References: <798108.90765.qm@web26108.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nj A <nj_a83@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41600 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757276AbXKNLMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 06:12:37 -0500
Content-Disposition: inline
In-Reply-To: <798108.90765.qm@web26108.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 09:26:18AM +0000, Nj A (nj_a83@yahoo.fr) wrote:
> /* The kernel TCP hashtable */
> struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
> .lhash_lock = __RW_LOCK_UNLOCKED (tcp_hashinfo.lhash_lock),
> .lhash_users = ATOMIC_INIT (0),
> .lhash_wait = __WAIT_QUEUE_HEAD_INITIALIZER (tcp_hashinfo.lhash_wait),
> };
> ...
> struct sock *sk;
> struct sk_buff *skb;
> skb = alloc_skb (MAX_TCP_HEADER + 15, GFP_KERNEL);
> if (skb == NULL)
> printk ("%s: Unable to allocate memory \n", __FUNCTION__);
> sk = inet_lookup (&tcp_hashinfo, ip_src, src_port, ip_dst, dst_port, inet_iif (skb));
> if (!sk)
> ...
> This portion of code seems to cause the kernel to panic due to dereferencing a NULL pointer.
> Can anyone please tell me what is the error above?
> Best Regards,
 
Where exactly? Likely in inet_iif(), since it dereferences dst (routing
info), which is not presented after simple alloc_skb().
You have to setup skb correctly, check how ip_rcv() does it.

-- 
	Evgeniy Polyakov
