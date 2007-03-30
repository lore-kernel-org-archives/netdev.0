From: "Samuel Ortiz" <samuel@sortiz.org>
Subject: Re: [git patches] net driver fixes
Date: 30 Mar 2007 07:46:27 -0000
Message-ID: <cyuyCPrK.1175240787.9348410.samuel@sortiz.org>
References: <Pine.LNX.4.63.0703300922490.534@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Guennadi Liakhovetski" <g.liakhovetski@gmx.de>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>
To: gl@dsa-ac.de, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([213.186.37.103]:50074 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753200AbXC3Hqa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 03:46:30 -0400
In-Reply-To: <Pine.LNX.4.63.0703300922490.534@pcgl.dsa-ac.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 3/30/2007, "Guennadi Liakhovetski" <gl@dsa-ac.de> wrote:

>On Thu, 29 Mar 2007, Jeff Garzik wrote:
>
>> Guennadi Liakhovetski wrote:
>>> Jeff, might be worth getting the sk_buff leak fix in ppp from
>>> http://www.spinics.net/lists/netdev/msg27706.html in 2.6.21 too?
>>>
>>> Don't know how important it is for stable. It was present in 2.6.18 too.
>>
>> Can you resend the patch to me, please?
>>
>> Easier for the system to apply than the URL...
>
>Sure, attached below. I think, though, this patch is already in someone's
>tree. Andrew has applied it to -mm under the name
>
>ppp-dont-leak-an-sk_buff-on-interface-destruction.patch
>
>but then dropped with the reasoning "This patch was dropped because it was
>merged into mainline or a subsystem tree". So, maybe it is now in Samuel's
>IrDA tree. Samuel?So, maybe all you have to do is to pull it from his
>tree.
It's already in Linus tree, and has landed there through davem's
net-2.6 tree.
So, this is all taken care of, Jeff doesn't need to worry about this one.

Cheers,
Samuel.


>Thanks
>Guennadi
>---------------------------------
>Guennadi Liakhovetski, Ph.D.
>DSA Daten- und Systemtechnik GmbH
>Pascalstr. 28
>D-52076 Aachen
>Germany
>
>Don't leak an sk_buff on interface destruction.
>
>Signed-off-by: G. Liakhovetski <gl@dsa-ac.de>
>
>--- a/drivers/net/ppp_generic.c	2007-03-23 13:04:04.000000000 +0100
>+++ b/drivers/net/ppp_generic.c	2007-03-23 13:05:29.000000000 +0100
>@@ -2544,6 +2544,9 @@
>  	ppp->active_filter = NULL;
>  #endif /* CONFIG_PPP_FILTER */
>
>+	if (ppp->xmit_pending)
>+		kfree_skb(ppp->xmit_pending);
>+
>  	kfree(ppp);
>  }
>
