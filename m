From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [ANNOUNCE] iproute2 v2.6.28
Date: Fri, 16 Jan 2009 20:06:39 +0100
Message-ID: <4970DABF.40200@hartkopp.net>
References: <20090115130845.01d7ebf4@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070201060907050709040908"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:65321 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761882AbZAPTGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 14:06:44 -0500
In-Reply-To: <20090115130845.01d7ebf4@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070201060907050709040908
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> New version of iproute2 utilities that includes bug fixes and
> support for all the new features in kernel 2.6.28.
>   

Hello Stephen,

your mail reminded me that some defines for the Controller Area Network 
(CAN) are still missing since 2.6.25.

It's not a big problem, but it makes a better show in 'ip link show' on 
CAN interfaces :-)

I also moved __PF(CAN,can) in ll_proto.c to the same position where it 
can be found in if_ether.h .

The only thing i did not know if the __PF(CAN,can) in ll_types.c needs 
to be put in #ifdef ARPHDR_CAN like __PF(HWX25,hwx25) is or not. You 
definitely know that better than me.

Regards,
Oliver


iproute2: add missing defines for Controller Area Network
Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>



--------------070201060907050709040908
Content-Type: text/x-patch;
 name="iproute2-2.6.28-can.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute2-2.6.28-can.patch"

diff -u -r iproute2-2.6.28-orig/ip/ipaddress.c iproute2-2.6.28/ip/ipaddress.c
--- iproute2-2.6.28-orig/ip/ipaddress.c	2009-01-15 21:25:04.000000000 +0100
+++ iproute2-2.6.28/ip/ipaddress.c	2009-01-16 19:33:22.000000000 +0100
@@ -109,6 +109,7 @@
 	_PF(UP);
 	_PF(LOWER_UP);
 	_PF(DORMANT);
+	_PF(ECHO);
 #undef _PF
         if (flags)
 		fprintf(fp, "%x", flags);
diff -u -r iproute2-2.6.28-orig/lib/ll_proto.c iproute2-2.6.28/lib/ll_proto.c
--- iproute2-2.6.28-orig/lib/ll_proto.c	2009-01-15 21:25:04.000000000 +0100
+++ iproute2-2.6.28/lib/ll_proto.c	2009-01-16 19:46:43.000000000 +0100
@@ -84,6 +84,7 @@
 __PF(WAN_PPP,wan_ppp)
 __PF(PPP_MP,ppp_mp)
 __PF(LOCALTALK,localtalk)
+__PF(CAN,can)
 __PF(PPPTALK,ppptalk)
 __PF(TR_802_2,tr_802_2)
 __PF(MOBITEX,mobitex)
@@ -94,7 +95,6 @@
 #endif
 __PF(TIPC,tipc)
 __PF(AOE,aoe)
-__PF(CAN,can)
 
 { 0x8100, "802.1Q" },
 { ETH_P_IP, "ipv4" },
diff -u -r iproute2-2.6.28-orig/lib/ll_types.c iproute2-2.6.28/lib/ll_types.c
--- iproute2-2.6.28-orig/lib/ll_types.c	2009-01-15 21:25:04.000000000 +0100
+++ iproute2-2.6.28/lib/ll_types.c	2009-01-16 19:27:35.000000000 +0100
@@ -70,6 +70,7 @@
 #ifdef ARPHRD_HWX25
 __PF(HWX25,hwx25)
 #endif
+__PF(CAN,can)
 __PF(PPP,ppp)
 __PF(HDLC,hdlc)
 __PF(LAPB,lapb)

--------------070201060907050709040908--
