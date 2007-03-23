From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: Re: [irda-users] [2.6.20-rt8] "Neighbour table overflow."
Date: Fri, 23 Mar 2007 13:14:43 +0100 (CET)
Message-ID: <Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
References: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org>
 <Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "irda-users@lists.sourceforge.net" <irda-users@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dsa-ac.de ([62.112.80.99]:43816 "EHLO mail.dsa-ac.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422838AbXCWMOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 08:14:45 -0400
In-Reply-To: <Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Mar 2007, Guennadi Liakhovetski wrote:

> On Wed, 21 Mar 2007, Samuel Ortiz wrote:
>
>> I'm quite sure the leak is in the IrDA code rather than in the ppp or
>> ipv4 one, hence the need for full irda debug...

Well, looks like you were wrong, Samuel. Below is a patch that fixes ONE 
sk_buff leak (maintainer added to cc: hi, Paul:-)). Still investigating if 
there are more there.

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany

Don't leak an sk_buff on interface destruction.

Signed-off-by: G. Liakhovetski <gl@dsa-ac.de>

--- a/drivers/net/ppp_generic.c	2007-03-23 13:04:04.000000000 +0100
+++ b/drivers/net/ppp_generic.c	2007-03-23 13:05:29.000000000 +0100
@@ -2544,6 +2544,9 @@
  	ppp->active_filter = NULL;
  #endif /* CONFIG_PPP_FILTER */

+	if (ppp->xmit_pending)
+		kfree_skb(ppp->xmit_pending);
+
  	kfree(ppp);
  }

