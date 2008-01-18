From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: [PATCH] IPv4: Enable use of 240/4 address space
Date: Fri, 18 Jan 2008 02:13:52 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801180023450.18447@fbirervta.pbzchgretzou.qr>
References: <20080108011057.GA21168@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Network Development Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	=?UTF-8?Q?YOSHIFUJI_Hideaki_=2F_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98?=
	 =?UTF-8?Q?=8E?= <yoshfuji@linux-ipv6.org>,
	Vince Fuller <vaf@cisco.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:53110 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbYARBNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 20:13:54 -0500
In-Reply-To: <20080108011057.GA21168@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 7 2008 17:10, Vince Fuller wrote:
>
>This set of diffs modify the 2.6.20 kernel to enable use of the 240/4
>(aka "class-E") address space as consistent with the Internet Draft
>draft-fuller-240space-00.txt.
>

Below is a patch against davem/net-2.6.25. It might look very spartan, 
but that is actually all that is needed on a sane system. No class E 
macros or so needed.

Only the ipv4_is_badclass() might need renaming if you think it really 
needs a name change. Or maybe a comment. Comments please :)

===
ancestor 7651a1f7ebe567f9088283f6354a5634b5dccb8e
commit 44762168d7cbefc4f8753a79d99a761cbd9875d9
Author: Jan Engelhardt <jengelh@computergmbh.de>
Date:   Fri Jan 18 02:10:44 2008 +0100

    IPv4: enable use of 240/4 address space
    
    This short patch modifies the IPv4 networking to enable use of the
    240.0.0.0/4 (aka "class-E") address space as propsed in the internet
    draft draft-fuller-240space-00.txt.
    
    Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>

diff --git a/include/linux/in.h b/include/linux/in.h
index 27d8a5a..b01bf75 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -216,9 +216,6 @@ struct sockaddr_in {
 #define	IN_MULTICAST(a)		IN_CLASSD(a)
 #define IN_MULTICAST_NET	0xF0000000
 
-#define	IN_EXPERIMENTAL(a)	((((long int) (a)) & 0xf0000000) == 0xf0000000)
-#define	IN_BADCLASS(a)		IN_EXPERIMENTAL((a))
-
 /* Address to accept any incoming messages. */
 #define	INADDR_ANY		((unsigned long int) 0x00000000)
 
@@ -264,7 +261,7 @@ static inline bool ipv4_is_local_multicast(__be32 addr)
 
 static inline bool ipv4_is_badclass(__be32 addr)
 {
-	return (addr & htonl(0xf0000000)) == htonl(0xf0000000);
+	return addr == 0xFFFFFFFF;
 }
 
 static inline bool ipv4_is_zeronet(__be32 addr)
