From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: (usagi-users 03612) Re: IPv6 setsockopt software MTU patch
Date: Mon, 20 Feb 2006 01:08:21 +0900 (JST)
Message-ID: <20060220.010821.123645153.yoshfuji@linux-ipv6.org>
References: <20060219134709.GC16304@clarinet.u-strasbg.fr>
	<20060219.231344.11160682.yoshfuji@linux-ipv6.org>
	<20060219145413.GD16304@clarinet.u-strasbg.fr>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, netdev@vger.kernel.org, olivier.matz@6wind.com,
        davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: hoerdt@clarinet.u-strasbg.fr
In-Reply-To: <20060219145413.GD16304@clarinet.u-strasbg.fr>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

In article <20060219145413.GD16304@clarinet.u-strasbg.fr> (at Sun, 19 Feb 2006 15:54:13 +0100), hoerdt@clarinet.u-strasbg.fr says:

> Yes, Hugo Santos suggested me to use the minimum of both, the new
> patch is available there :
> 
> http://clarinet.u-strasbg.fr/~hoerdt/ip6_output.c.softfrag.patch2

Do you mean like this?

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index efa3e72..3264740 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -494,6 +494,7 @@ static int ip6_fragment(struct sk_buff *
 	struct net_device *dev;
 	struct sk_buff *frag;
 	struct rt6_info *rt = (struct rt6_info*)skb->dst;
+	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
 	struct ipv6hdr *tmp_hdr;
 	struct frag_hdr *fh;
 	unsigned int mtu, hlen, left, len;
@@ -506,6 +507,8 @@ static int ip6_fragment(struct sk_buff *
 	nexthdr = *prevhdr;
 
 	mtu = dst_mtu(&rt->u.dst) - hlen - sizeof(struct frag_hdr);
+	if (np && np->frag_size && np->frag_size < dst_mtu(&rt->u.dst))
+		mtu = np->frag_size - hlen - sizeof(struct frag_hdr);
 
 	if (skb_shinfo(skb)->frag_list) {
 		int first_len = skb_pagelen(skb);


-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
