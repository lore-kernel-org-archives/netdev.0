From: David Miller <davem@davemloft.net>
Subject: another tulip typo (Fw: Unaligned accesses in ip_rcv and
 ip_fast_csum)
Date: Tue, 27 Feb 2007 11:59:42 -0800 (PST)
Message-ID: <20070227.115942.34602032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Tue_Feb_27_11_59_42_2007_057)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752519AbXB0T7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 14:59:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----Next_Part(Tue_Feb_27_11_59_42_2007_057)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Another one of those __sparc_ --> __sparc__ typos in Tulip,
Jeff please apply.

Signed-off-by: David S. Miller <davem@davemloft.net>

----Next_Part(Tue_Feb_27_11_59_42_2007_057)--
Content-Type: Message/Rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Return-Path: <davem@vger.kernel.org>
X-Original-To: davem@sunset.davemloft.net
Delivered-To: davem@sunset.davemloft.net
Received: from vger.kernel.org (vger.kernel.org [209.132.176.167])
	by sunset.davemloft.net (Postfix) with ESMTP id 03BB7AE4212
	for <davem@sunset.davemloft.net>; Tue, 27 Feb 2007 11:43:30 -0800 (PST)
Received: (from localhost user: 'davem' uid#2109 fake: STDIN
	(davem@vger.kernel.org)) by vger.kernel.org id S1752054AbXB0Tn1
	(ORCPT <rfc822;davem@sunset.davemloft.net>);
	Tue, 27 Feb 2007 14:43:27 -0500
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id S1752093AbXB0Tn0 (ORCPT <rfc822;davem@davemloft.net>);
	Tue, 27 Feb 2007 14:43:26 -0500
Received: (majordomo@vger.kernel.org) by vger.kernel.org id S1752505AbXB0Tn0
	(ORCPT <rfc822;sparclinux-outgoing>);
	Tue, 27 Feb 2007 14:43:26 -0500
Received: from slyph.dragoninc.ca ([216.208.25.187]:4795 "EHLO
	slyph.dragoninc.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbXB0TnZ (ORCPT
	<rfc822;sparclinux@vger.kernel.org>); Tue, 27 Feb 2007 14:43:25 -0500
Received: (qmail 16438 invoked by uid 210); 27 Feb 2007 14:43:24 -0500
Received: from 216.220.55.30 (nazard@216.220.55.30) by slyph (envelope-from <nazard@dragoninc.ca>, uid 201) with qmail-scanner-2.01st
 (clamdscan: devel-20061027/2657. perlscan: 2.01st.  
 Clear:RC:1(216.220.55.30):.
 Processed in 0.041453 secs); 27 Feb 2007 19:43:24 -0000
Received: from chrysler.nhlpa.com (HELO hastur) (nazard@216.220.55.30)
  by slyph.dragoninc.ca with ESMTPA; 27 Feb 2007 14:43:23 -0500
From: "Doug Nazar" <nazard@dragoninc.ca>
To: "'Jurij Smakov'" <jurij@wooyd.org>
Cc: <sparclinux@vger.kernel.org>
References: <20070225200702.GA4451@droopy.oc.cox.net>
In-Reply-To: <20070225200702.GA4451@droopy.oc.cox.net>
Subject: RE: Unaligned accesses in ip_rcv and ip_fast_csum
Date: Tue, 27 Feb 2007 14:43:23 -0500
Message-ID: <00e801c75aa7$8af0e5b0$a0d2b110$@ca>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Office Outlook 12.0
Thread-Index: AcdZGLCVxqFDWUaiSB+0yhz0gVeyzgBjrI0w
Content-Language: en-us
Sender: "David S. Miller" <davem@vger.kernel.org>
Fake-Sender: sparclinux-owner@vger.kernel.org
Precedence: bulk
X-Mailing-List: sparclinux@vger.kernel.org

> We have a report (Debian bug #409313 [0]) of the following unaligned
> accesses, occuring every 5-6 seconds on Netra X1 and SunFire v100 with
> kernel 2.6.18 and newer:

A quick grep shows this issue is also in de2104x module in case somebody is
using that.

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 9d67f11..dacea4f 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -63,7 +63,7 @@ MODULE_PARM_DESC (debug, "de2104x bitmapped message enable
number");
 
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
-        || defined(__sparc_) || defined(__ia64__) \
+        || defined(__sparc__) || defined(__ia64__) \
         || defined(__sh__) || defined(__mips__)
 static int rx_copybreak = 1518;
 #else

-
To unsubscribe from this list: send the line "unsubscribe sparclinux" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

----Next_Part(Tue_Feb_27_11_59_42_2007_057)----
