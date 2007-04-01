From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Silent corruption on AMD64
Date: 01 Apr 2007 15:58:59 +0200
Message-ID: <p737iswqjq4.fsf@bingen.suse.de>
References: <20070401012736.GT15189@vitelus.com>
	<20070401030315.GA24080@jim.sh> <20070401043905.GV15189@vitelus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jim Paris <jim@jtan.com>, linux-kernel@vger.kernel.org,
	linux-ide@vger.kernel.org, netdev@vger.kernel.org
To: Aaron Lehmann <aaronl@vitelus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37920 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933045AbXDANA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Apr 2007 09:00:29 -0400
In-Reply-To: <20070401043905.GV15189@vitelus.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aaron Lehmann <aaronl@vitelus.com> writes:

[adding netdev]
[meta-comment: I wish people wouldn't use such unnecessarily broad subjects 
-- how is it the x86-64 port's or AMD's fault when you have broken hardware? 
Would anybody write "Silent corruption on i386" or "Silent corruption 
on Intel" or "Silent corruption on Linux"?]

> On Sat, Mar 31, 2007 at 08:03:16PM -0700, Jim Paris wrote:
> > Since it shows up under heavy load that includes unrelated devices, I
> > think ruling out hardware problems is important.  Some suggestions:
> 
> I've been able to narrow it down to the Realtek Ethernet card. I can't
> reproduce the problem using onboard Ethernet, whereas the Realtek card
> causes trouble in any slot. However, I still don't know whether it's a
> hardware or software issue, or whether it's caused directly or
> indirectly by the Realtek card.

You could disable the hardware checksumming support in the card with
the appended patch. Then hopefully Linux will catch most corruptions
(but perhaps not all because TCP checksums are not very strong) 
You can watch failed checksums then with netstat -s

-Andi

Index: linux-2.6.21-rc3-net/drivers/net/r8169.c
===================================================================
--- linux-2.6.21-rc3-net.orig/drivers/net/r8169.c
+++ linux-2.6.21-rc3-net/drivers/net/r8169.c
@@ -2477,6 +2477,7 @@ static inline int rtl8169_fragmented_fra
 
 static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc *desc)
 {
+#if 0
 	u32 opts1 = le32_to_cpu(desc->opts1);
 	u32 status = opts1 & RxProtoMask;
 
@@ -2485,6 +2486,7 @@ static inline void rtl8169_rx_csum(struc
 	    ((status == RxProtoIP) && !(opts1 & IPFail)))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	else
+#endif
 		skb->ip_summed = CHECKSUM_NONE;
 }
 

