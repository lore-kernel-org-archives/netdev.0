From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Fw: kernel BUG at net/core/skbuff.c:1028!
Date: Thu, 08 May 2003 11:20:27 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030508012101.36E012C01B@lists.samba.org>
References: <20030507.042003.26512841.davem@redhat.com>
Cc: laforge@netfilter.org, Jens Axboe <axboe@suse.de>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Wed, 07 May 2003 04:20:03 MST."
             <20030507.042003.26512841.davem@redhat.com>
List-Id: netdev.vger.kernel.org

In message <20030507.042003.26512841.davem@redhat.com> you write:
> It has to be from some of the skb linearization changes.
> I can't think of any other change we've made that would
> make this start to happen.

Yep, culprit is obvious stupid bug.  This indicates a serious lack of
testing on my part 8(

Jens, does this help?
Rusty.

diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.69-bk2/net/ipv4/netfilter/ip_nat_core.c working-2.5.69-bk2-fix-nat/net/ipv4/netfilter/ip_nat_core.c
--- linux-2.5.69-bk2/net/ipv4/netfilter/ip_nat_core.c	2003-05-08 10:31:08.000000000 +1000
+++ working-2.5.69-bk2-fix-nat/net/ipv4/netfilter/ip_nat_core.c	2003-05-08 11:19:04.000000000 +1000
@@ -870,7 +870,8 @@ icmp_reply_translation(struct sk_buff **
 	   adjustment, so make sure the current checksum is correct. */
 	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY
 	    && (u16)csum_fold(skb_checksum(*pskb, (*pskb)->nh.iph->ihl*4,
-					   (*pskb)->len, 0)))
+					   (*pskb)->len
+					   - (*pskb)->nh.iph->ihl*4, 0)))
 		return 0;
 
 	/* Must be RELATED */


--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
