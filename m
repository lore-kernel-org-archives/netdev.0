From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPsec support
Date: Tue, 18 Feb 2003 23:13:24 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218.231324.44469350.davem@redhat.com>
References: <20030219134850.5f203ea7.Kazunori.Miyazawa@jp.yokogawa.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori.Miyazawa@jp.yokogawa.com
In-Reply-To: <20030219134850.5f203ea7.Kazunori.Miyazawa@jp.yokogawa.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori MIyazawa <Kazunori.Miyazawa@jp.yokogawa.com>
   Date: Wed, 19 Feb 2003 13:48:50 +0900

   Please let me know if you have some ideas and/or comments.

Hello again Miyazawa-san, I give you my initial comment.

I see very quickly that the ipv6 side of implementation will
give lots of opportunity for code sharing.  But we must plan
it correctly :-)
   
I also wish to avoid exporting internal xfrm objects to ipv6 module.

So, let us discuss one example:
   
   diff -urN linux-2.5.62/net/ipv4/xfrm_input.c linux25_for_patch/net/ipv4/xfrm_input.c
   --- linux-2.5.62/net/ipv4/xfrm_input.c	2003-02-18 07:55:50.000000000 +0900
   +++ linux25_for_patch/net/ipv4/xfrm_input.c	2003-02-19 02:36:53.000000000 +0900
   @@ -1,7 +1,7 @@
    #include <net/ip.h>
    #include <net/xfrm.h>
    
   -static kmem_cache_t *secpath_cachep;
   +kmem_cache_t *secpath_cachep;
    
    void __secpath_destroy(struct sec_path *sp)
    {

I understand why you need this, for xfrm6_rcv().  This is fine.

However, it would be even better to put xfrm6_rcv() into
net/ipv4/xfrm_input.c, protected by CONFIG_IPV6 || CONFIG_IPV6_MODULE
ifdef.

In this way we may split out identical pieces of code which
occur in xfrm4_rcv() and xfrm6_rcv().  Then we merely need
to export the xfrm6_rcv symbol for sake of ipv6 as module.

In fact, nearly %90 of these two functions are identical.
