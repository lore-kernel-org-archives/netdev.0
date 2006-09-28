From: Douglas Leith <doug.leith@nuim.ie>
Subject: Re the default linux tcp algorithm being changed from bic to cubic.
Date: Thu, 28 Sep 2006 11:07:18 +0100
Message-ID: <451B9ED6.9090208@nuim.ie>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: Douglas Leith <doug.leith@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:52221 "EHLO LARCH.MAY.IE")
	by vger.kernel.org with ESMTP id S1751794AbWI1KI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 06:08:58 -0400
Received: from [10.220.3.214] ([149.157.192.252])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01M7Q5PTG07G00VAW2@NUIM.IE>
 for netdev@vger.kernel.org; Thu, 28 Sep 2006 11:09:00 +0000 (GMT)
To: shemminger@osdl.org, netdev <netdev@vger.kernel.org>,
	davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Steve,

I think we're all conscious of the fact that recent history contains 
quite a number of proposals for changes to tcp's congestion control 
algorithm for high bandwidth-delay product paths that on closer 
inspection have proved problematic in one way or another.   It seems to 
be a hard problem to solve, so maybe that's fair enough and hopefully 
we'll end up with a workable solution soon.

Where I'm coming from here though is that bic was made the linux default 
a year or so ago at a time when there were essentially no tests 
available on its performance other than the infocom paper by Injong. 
Subsequent tests have since highlighted a bunch of issues with bic.  To 
my knowledge, we're currently in a similar situation with cubic as we 
were with bic back then i.e. essentially no independent tests 
investigating its behaviour.

Of course I know Injong has posted some test results, but these are 
hardly independent as he's the author of both bic and cubic.  Have there 
perhaps been private tests carried out (e.g. by osdl) ?  If so, would it 
be possible to make them public ?  If not, well that would be good to 
know too.

Doug

Hamilton Institute
www.hamilton.ie



------- Original Message --------
Subject: [TCP]: make cubic the default
Date: Tue, 26 Sep 2006 00:59:56 GMT
From: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: git-commits-head@vger.kernel.org

commit 597811ec167fa01c926a0957a91d9e39baa30e64
tree 24e6ce26a4464d21993f2cd17dbdb9aec13360ab
parent 3d2573f7ebe507e372a23cdd3c8b03305d6e90aa
author Stephen Hemminger <shemminger@osdl.org> 1159153983 -0700
committer David S. Miller <davem@davemloft.net> 1159153983 -0700

[TCP]: make cubic the default

Change default congestion control used from BIC to the newer CUBIC
which it the successor to BIC but has better properties over long delay
links.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: David S. Miller <davem@davemloft.net>

  net/ipv4/Kconfig |   12 ++++++------
  1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 1bbc368..30af4a4 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -455,7 +455,7 @@ menuconfig TCP_CONG_ADVANCED
  	  modules.

  	  Nearly all users can safely say no here, and a safe default
-	  selection will be made (BIC-TCP with new Reno as a fallback).
+	  selection will be made (CUBIC with new Reno as a fallback).

  	  If unsure, say N.

@@ -463,7 +463,7 @@ if TCP_CONG_ADVANCED

  config TCP_CONG_BIC
  	tristate "Binary Increase Congestion (BIC) control"
-	default y
+	default m
  	---help---
  	BIC-TCP is a sender-side only change that ensures a linear RTT
  	fairness under large windows while offering both scalability and
@@ -477,7 +477,7 @@ config TCP_CONG_BIC

  config TCP_CONG_CUBIC
  	tristate "CUBIC TCP"
-	default m
+	default y
  	---help---
  	This is version 2.0 of BIC-TCP which uses a cubic growth function
  	among other techniques.
@@ -574,7 +574,7 @@ config TCP_CONG_VENO

  choice
  	prompt "Default TCP congestion control"
-	default DEFAULT_BIC
+	default DEFAULT_CUBIC
  	help
  	  Select the TCP congestion control that will be used by default
  	  for all connections.
@@ -601,7 +601,7 @@ endchoice

  endif

-config TCP_CONG_BIC
+config TCP_CONG_CUBIC
  	tristate
  	depends on !TCP_CONG_ADVANCED
  	default y
@@ -614,7 +614,7 @@ config DEFAULT_TCP_CONG
  	default "vegas" if DEFAULT_VEGAS
  	default "westwood" if DEFAULT_WESTWOOD
  	default "reno" if DEFAULT_RENO
-	default "bic"
+	default "cubic"

  source "net/ipv4/ipvs/Kconfig"

-
To unsubscribe from this list: send the line "unsubscribe
git-commits-head" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
