From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Mon, 31 Jan 2005 13:45:59 +0900 (JST)
Message-ID: <20050131.134559.125426676.yoshfuji@linux-ipv6.org>
References: <41FD2043.3070303@trash.net>
	<E1CvSuS-00056x-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, rmk+lkml@arm.linux.org.uk, Robert.Olsson@data.slu.se,
        akpm@osdl.org, torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au, davem@davemloft.net
In-Reply-To: <E1CvSuS-00056x-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <E1CvSuS-00056x-00@gondolin.me.apana.org.au> (at Mon, 31 Jan 2005 15:11:32 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> Patrick McHardy <kaber@trash.net> wrote:
> > 
> > Ok, final decision: you are right :) conntrack also defragments locally
> > generated packets before they hit ip_fragment. In this case the fragments
> > have skb->dst set.
> 
> Well caught.  The same thing is needed for IPv6, right?

(not yet confirmed, but) yes, please.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/ip6_output.c 1.82 vs edited =====
--- 1.82/net/ipv6/ip6_output.c	2005-01-25 09:40:10 +09:00
+++ edited/net/ipv6/ip6_output.c	2005-01-31 13:44:01 +09:00
@@ -463,6 +463,7 @@
 	to->priority = from->priority;
 	to->protocol = from->protocol;
 	to->security = from->security;
+	dst_release(to->dst);
 	to->dst = dst_clone(from->dst);
 	to->dev = from->dev;
 

--yoshfuji
