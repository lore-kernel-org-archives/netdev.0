From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: IPsec and Path MTU
Date: Fri, 18 Jun 2004 17:05:29 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087544129.9044.27.camel@andromache>
References: <20040615124334.GA25164@gondor.apana.org.au>
	 <32703.1087311037@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <32703.1087311037@marajade.sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-06-16 at 00:20, Michael Richardson wrote:

>   The pmtu WG is considering changing how PMTU is done. You may want to 
> look at draft-richardson-ipsec-fragment-XX.txt. This has not yet been
> adopted as a WG draft, because nobody is sure which WG should adopt it:-)

As well as longer term efforts you might note that altering
the RFC1191 plateau table in the kernel to add 9000 would
result in 10% less jumbo frames.

The large absolute packet sizes are going to doom the plateau
table approach at the next increase in MTU size. Hopefully
Matt and your efforts we see deployment before then.

Cheers,
Glen


diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Fri Oct 24 13:23:50 2003
+++ b/net/ipv4/route.c	Fri Oct 24 13:23:50 2003
@@ -1222,10 +1222,14 @@
 /*
  *	The last two values are not from the RFC but
  *	are needed for AMPRnet AX.25 paths.
+ *      The RFC has written before ethernet jumbo frames.
+ *      Since these are the dominant large MTU we add them
+ *      as using 8166 would lead to 10% more packets (a lot
+ *      of CPU at 1Gbps).
  */
 
 static unsigned short mtu_plateau[] =
-{32000, 17914, 8166, 4352, 2002, 1492, 576, 296, 216, 128 };
+{32000, 17914, 9000, 8166, 4352, 2002, 1492, 576, 296, 216, 128 };
 
 static __inline__ unsigned short guess_mtu(unsigned short old_mtu)
 {
