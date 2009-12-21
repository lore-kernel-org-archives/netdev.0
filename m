From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Mon, 21 Dec 2009 21:50:34 +0100
Message-ID: <200912212150.34727.schmto@hrz.tu-chemnitz.de>
References: <4B298118.2000608@redfish-solutions.com> <200912171724.32711.schmto@hrz.tu-chemnitz.de> <4B2A8A5C.9070702@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_a+9LLMdRAstRRLs"
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.hrz.tu-chemnitz.de ([134.109.132.46]:56710 "EHLO
	jack.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbZLUUuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 15:50:39 -0500
In-Reply-To: <4B2A8A5C.9070702@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_a+9LLMdRAstRRLs
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

Hi Philip,

here a second PATCH to add the missing DSCP classes to 
ipv4_dscp_stat(), also tested against 2.6.32. 

Next step is to add IN / OUT statistic to DSCP. Maybe 
/proc/net/ipdscp will look like:
CS0	in	out
CS1	in	out
...
EF	in	out


any comments ?
Torsten

--Boundary-00=_a+9LLMdRAstRRLs
Content-Type: text/x-patch;
  charset="UTF-8";
  name="0002-ipv4-add-missing-DSCP-classes.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0002-ipv4-add-missing-DSCP-classes.patch"

=46rom 58a2a79f4083fa614637cab13fe7df99b92b6fcf Mon Sep 17 00:00:00 2001
=46rom: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
Date: Mon, 21 Dec 2009 21:30:44 +0100
Subject: [PATCH 2/2] ipv4: add missing DSCP classes

This patch adds the missing IANA DSCP registry entries to ipv4 DSCP
statistic counter. See /proc/net/ipdscp

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
=2D--
 include/net/ipdscp.h |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/include/net/ipdscp.h b/include/net/ipdscp.h
index d5bce81..14cc8a6 100644
=2D-- a/include/net/ipdscp.h
+++ b/include/net/ipdscp.h
@@ -58,7 +58,25 @@ static inline void ipv4_dscp_stat(struct net *net, __u8 =
dsfield)
 	switch (dsfield >> 2) {
 	case IP_DSCP_CS0:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS0);break;
 	case IP_DSCP_EF:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_EF);break;
=2D	/* add new entrys here ... */
+	case IP_DSCP_CS1:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS1);break;
+	case IP_DSCP_CS2:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS2);break;
+	case IP_DSCP_CS3:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS3);break;
+	case IP_DSCP_CS4:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS4);break;
+	case IP_DSCP_CS5:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS5);break;
+	case IP_DSCP_CS6:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS6);break;
+	case IP_DSCP_CS7:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS7);break;
+	case IP_DSCP_AF11:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF11);break;
+	case IP_DSCP_AF12:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF12);break;
+	case IP_DSCP_AF13:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF13);break;
+	case IP_DSCP_AF21:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF21);break;
+	case IP_DSCP_AF22:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF22);break;
+	case IP_DSCP_AF23:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF23);break;
+	case IP_DSCP_AF31:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF31);break;
+	case IP_DSCP_AF32:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF32);break;
+	case IP_DSCP_AF33:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF33);break;
+	case IP_DSCP_AF41:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF41);break;
+	case IP_DSCP_AF42:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF42);break;
+	case IP_DSCP_AF43:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF43);break;
 	}
 }
=20
=2D-=20
1.6.3.3


--Boundary-00=_a+9LLMdRAstRRLs--
