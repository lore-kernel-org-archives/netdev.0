From: Nj A <nj_a83@yahoo.fr>
Subject: Bug in using inet_lookup ()
Date: Wed, 14 Nov 2007 09:26:18 +0000 (GMT)
Message-ID: <798108.90765.qm@web26108.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26108.mail.ukl.yahoo.com ([217.146.182.149]:33589 "HELO
	web26108.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751408AbXKNJ0U convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 04:26:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear All,
I need to use the inet_lookup function to find the sock structure of a TCP connection in a SYN_RECV state.
Here is what I used to do so:
/* The kernel TCP hashtable */
struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
.lhash_lock = __RW_LOCK_UNLOCKED (tcp_hashinfo.lhash_lock),
.lhash_users = ATOMIC_INIT (0),
.lhash_wait = __WAIT_QUEUE_HEAD_INITIALIZER (tcp_hashinfo.lhash_wait),
};
...
struct sock *sk;
struct sk_buff *skb;
skb = alloc_skb (MAX_TCP_HEADER + 15, GFP_KERNEL);
if (skb == NULL)
printk ("%s: Unable to allocate memory \n", __FUNCTION__);
sk = inet_lookup (&tcp_hashinfo, ip_src, src_port, ip_dst, dst_port, inet_iif (skb));
if (!sk)
...
This portion of code seems to cause the kernel to panic due to dereferencing a NULL pointer.
Can anyone please tell me what is the error above?
Best Regards,


      _____________________________________________________________________________ 
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo! Mail 
