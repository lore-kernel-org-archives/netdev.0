From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question about QOS
Date: Fri, 29 Apr 2005 14:16:50 +0200
Message-ID: <427225B2.6010705@trash.net>
References: <426E06F1.9000105@6wind.com> <20050426125955.GT577@postel.suug.ch> <426E56DC.7000108@6wind.com> <20050426191454.GU577@postel.suug.ch> <426F42F0.9020609@6wind.com> <20050427114216.GV577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030708050507000800080306"
Cc: Nicolas DICHTEL <nicolas.dichtel@6wind.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050427114216.GV577@postel.suug.ch>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030708050507000800080306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Thomas Graf wrote:
> * Nicolas DICHTEL <426F42F0.9020609@6wind.com> 2005-04-27 09:44
> 
>>>Yes I agree, it doesn't really matter what value we return and `bound'
>>>is most likely to be correct. I think we should also fix the unlikely
>>>but still possible case when tv1.tv_usec is slightly smaller than
>>>tv2.tv_usec. I know it is very unlikely but do_gettimeofday really
>>>is not that reliable and we have users which rely on a positive
>>>delta. Can you extend your patch to return abs(delta) for case 0
>>>in PSCHED_TDIFF_SAFE?

Why abs(delta)? It could be above bound, in fact all cases besides
delta_sec > 2 doesn't take care to stay inside [0..bound] at all.


--------------030708050507000800080306
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[PKT_SCHED]: Fix range in PSCHED_TDIFF_SAFE to 0..bound

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d5f65671be760f33c1c7667f793ed75ad6e6a710
tree 4af3018396f125b0c2601882d924e63a0d74bef4
parent 980207c270e72e2cc6ae7b0de6ea6cd38a726e5b
author Patrick McHardy <kaber@trash.net> 1114776755 +0200
committer Patrick McHardy <kaber@trash.net> 1114776755 +0200

Index: include/net/pkt_sched.h
===================================================================
--- e38e7620d369bfa898a2e3f6aaf2f04c8826f38e/include/net/pkt_sched.h  (mode:100644 sha1:7352e455053cc857e70f0cb1e008eb7adabbe011)
+++ 4af3018396f125b0c2601882d924e63a0d74bef4/include/net/pkt_sched.h  (mode:100644 sha1:fcb05a387dbee560d6a0f20b6e8c3c4f1b2d93f1)
@@ -157,7 +157,8 @@
 	   case 1: \
 		   __delta += 1000000; \
 	   case 0: \
-		   __delta = abs(__delta); \
+ 		   if (__delta > bound || __delta < 0) \
+ 			__delta = bound; \
 	   } \
 	   __delta; \
 })

--------------030708050507000800080306--
