From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 29 Mar 2010 09:50:56 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1003290946320.13721@router.home>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org> <alpine.DEB.2.00.1003221146260.17230@router.home> <877hp4i76d.fsf@basil.now
 <20100327131138.GD20695@one.firstfloor.org> <4BAE382D.7090903@250bpm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:55839 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175Ab0C2OyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 10:54:16 -0400
In-Reply-To: <4BAE382D.7090903@250bpm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 Mar 2010, Martin Sustrik wrote:

> Andi Kleen wrote:
>
> > I did a quick read and the manpage/interface seem reasonable to me.
>
> You may also have a look at original PGM implementation by Luigi Rizzo
> (FreeBSD). It's not maintained, but it might give you broader view.
>
> http://info.iet.unipi.it/~luigi/pgm-code/

Interesting. Which files in that directory contain the most current code?

Looks like the tcpdump patch has been merged.

Here is another tcpdump patch that implements decoding PGM via UDP. Anyone
know how to submit something like that?

(Need to specify -Tpgm option to use pgm decoder on UDP traffic)

Index: tcpdump/interface.h
===================================================================
--- tcpdump.orig/interface.h	2010-02-26 18:50:39.411609391 -0600
+++ tcpdump/interface.h	2010-02-26 18:51:04.270350179 -0600
@@ -74,6 +74,7 @@
 #define PT_CNFP		7	/* Cisco NetFlow protocol */
 #define PT_TFTP		8	/* trivial file transfer protocol */
 #define PT_AODV		9	/* Ad-hoc On-demand Distance Vector Protocol */
+#define PT_PGM		10	/* The PGM protocol */

 #ifndef min
 #define min(a,b) ((a)>(b)?(b):(a))
Index: tcpdump/print-udp.c
===================================================================
--- tcpdump.orig/print-udp.c	2010-02-26 18:51:35.921610552 -0600
+++ tcpdump/print-udp.c	2010-02-26 18:53:54.440349950 -0600
@@ -520,6 +520,11 @@
 			tftp_print(cp, length);
 			break;

+		case PT_PGM:
+			udpipaddr_print(ip, sport, dport);
+			pgm_print(cp, length, (const u_char *)ip);
+			break;
+
 		case PT_AODV:
 			udpipaddr_print(ip, sport, dport);
 			aodv_print((const u_char *)(up + 1), length,
Index: tcpdump/tcpdump.c
===================================================================
--- tcpdump.orig/tcpdump.c	2010-02-26 18:37:13.971601597 -0600
+++ tcpdump/tcpdump.c	2010-02-26 18:37:43.290033748 -0600
@@ -854,6 +854,8 @@
 				packettype = PT_TFTP;
 			else if (strcasecmp(optarg, "aodv") == 0)
 				packettype = PT_AODV;
+			else if (strcasecmp(optarg, "pgm") == 0)
+				packettype = PT_PGM;
 			else
 				error("unknown packet type `%s'", optarg);
 			break;
