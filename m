From: "Eric S. Raymond" <esr@thyrsus.com>
Subject: [PATCH] tc-stab.8: Fix synopsis errors, an invalid escape, and
 incorrect English usge.
Date: Sun, 30 Jun 2013 20:02:47 -0400
Message-ID: <20130701000247.GA31460@thyrsus.com>
Reply-To: esr@thyrsus.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:49261
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab3GAACx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 20:02:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The command synopsis is regularized and part of it split off into an
OPTIONS section.  This allows the page to lift to XML-DocBook.

An invalid \p escape was removed.

This page was written by someone who didn't understand the use of
definite and indefinite articles in English, nor its punctuation rules.
I've fixed these mistakes, and some glitches in punctuation and
capitalization.
---
 man/man8/tc-stab.8 | 60 +++++++++++++++++++++++++++---------------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

diff --git a/man/man8/tc-stab.8 b/man/man8/tc-stab.8
index 522ea00..02caa7d 100644
--- a/man/man8/tc-stab.8
+++ b/man/man8/tc-stab.8
@@ -5,15 +5,15 @@ tc\-stab \- Generic size table manipulations
 .
 .SH SYNOPSIS
 .nf
-tc qdisc add ... stab \\
+tc qdisc add ... stab
 .RS 4
-[ \fBmtu\fR BYTES ] [ \fBtsize\fR SLOTS ] \\
-[ \fBmpu\fR BYTES ] [ \fBoverhead\fR BYTES ] [ \fBlinklayer\fR TYPE ] ...
+[ \fBmtu\fR BYTES ] [ \fBtsize\fR SLOTS ]
+[ \fBmpu\fR BYTES ] [ \fBoverhead\fR BYTES ]
+[ \fBlinklayer\fR { adsl | atm | ethernet } ] ...
 .RE
-
-TYPE := adsl | atm | ethernet
 .fi
 
+.SH OPTIONS
 For the description of BYTES \- please refer to the \fBUNITS\fR
 section of \fBtc\fR(8).
 
@@ -31,27 +31,27 @@ minimum packet size used in computations
 per\-packet size overhead (can be negative) used in computations
 .IP \fBlinklayer\fR
 .br
-required linklayer adaptation.
+required linklayer specification.
 .PP
 .
 .SH DESCRIPTION
 .
-Size tables allow manipulation of packet size, as seen by whole scheduler
+Size tables allow manipulation of packet sizes, as seen by the whole scheduler
 framework (of course, the actual packet size remains the same). Adjusted packet
 size is calculated only once \- when a qdisc enqueues the packet. Initial root
 enqueue initializes it to the real packet's size.
 
-Each qdisc can use different size table, but the adjusted size is stored in
-area shared by whole qdisc hierarchy attached to the interface. The effect is,
-that if you have such setup, the last qdisc with a stab in a chain "wins". For
+Each qdisc can use a different size table, but the adjusted size is stored in
+an area shared by whole qdisc hierarchy attached to the interface. The effect is
+that if you have such a setup, the last qdisc with a stab in a chain "wins". For
 example, consider HFSC with simple pfifo attached to one of its leaf classes.
 If that pfifo qdisc has stab defined, it will override lengths calculated
-during HFSC's enqueue, and in turn, whenever HFSC tries to dequeue a packet, it
-will use potentially invalid size in its calculations. Normal setups will
+during HFSC's enqueue; and in turn, whenever HFSC tries to dequeue a packet, it
+will use a potentially invalid size in its calculations. Normal setups will
 usually include stab defined only on root qdisc, but further overriding gives
 extra flexibility for less usual setups.
 
-Initial size table is calculated by \fBtc\fR tool using \fBmtu\fR and
+The initial size table is calculated by \fBtc\fR tool using \fBmtu\fR and
 \fBtsize\fR parameters. The algorithm sets each slot's size to the smallest
 power of 2 value, so the whole \fBmtu\fR is covered by the size table. Neither
 \fBtsize\fR, nor \fBmtu\fR have to be power of 2 value, so the size
@@ -65,12 +65,12 @@ depend on \fBlinklayer\fR parameter.
 Stab calculation is also safe for an unusual case, when a size assigned to a
 slot would be larger than 2^16\-1 (you will lose the accuracy though).
 
-During kernel part of packet size adjustment, \fBoverhead\fR will be added to
-original size, and then slot will be calculated. If the size would cause
-overflow, more than 1 slot will be used to get the final size. It of course
+During the kernel part of packet size adjustment, \fBoverhead\fR will be added
+to original size, and then slot will be calculated. If the size would cause
+overflow, more than 1 slot will be used to get the final size. This of course
 will affect accuracy, but it's only a guard against unusual situations.
 
-Currently there're two methods of creating values stored in the size table \-
+Currently there are two methods of creating values stored in the size table \-
 ethernet and atm (adsl):
 
 .IP ethernet 4
@@ -78,7 +78,7 @@ ethernet and atm (adsl):
 This is basically 1\-1 mapping, so following our example from above
 (disregarding \fBmpu\fR for a moment) slot 0 would have 8, slot 1 would have 16
 and so on, up to slot 127 with 2048. Note, that \fBmpu\fR\~>\~0 must be
-specified, and slots that would get less than specified by \fBmpu\fR, will get
+specified, and slots that would get less than specified by \fBmpu\fR will get
 \fBmpu\fR instead. If you don't specify \fBmpu\fR, the size table will not be
 created at all (it wouldn't make any difference), although any \fBoverhead\fR
 value will be respected during calculations.
@@ -88,7 +88,7 @@ ATM linklayer consists of 53 byte cells, where each of them provides 48 bytes
 for payload. Also all the cells must be fully utilized, thus the last one is
 padded if/as necessary.
 
-When size table is calculated, adjusted size that fits properly into lowest
+When the size table is calculated, adjusted size that fits properly into lowest
 amount of cells is assigned to a slot. For example, a 100 byte long packet
 requires three 48\-byte payloads, so the final size would require 3 ATM cells
 \- 159 bytes.
@@ -118,22 +118,22 @@ Bridged \- 24+ (ATM \- 10, ethernet 14, possibly FCS \- 4+padding)
 IPoA \- 8 (ATM \- 8)
 .RE
 .fi
-\p There're few important things regarding the above overheads:
+There are a few important things regarding the above overheads:
 .
 .IP \(bu 4
 IPoA in LLC case requires SNAP, instead of LLC\-NLPID (see rfc2684) \- this is
-the reason, why it actually takes more space than PPPoA.
+the reason why it actually takes more space than PPPoA.
 .IP \(bu
-In rare cases, FCS might be preserved on protocols that include ethernet frame
-(Bridged and PPPoE). In such situation, any ethernet specific padding
-guaranteeing 64 bytes long frame size has to be included as well (see rfc2684).
+In rare cases, FCS might be preserved on protocols that include Ethernet frames
+(Bridged and PPPoE). In such situation, any Ethernet specific padding
+guaranteeing 64 bytes long frame size has to be included as well (see RFC2684).
 In the other words, it also guarantees that any packet you send will take
 minimum 2 atm cells. You should set \fBmpu\fR accordingly for that.
 .IP \(bu
-When size table is consulted, and you're shaping traffic for the sake of
-another modem/router, ethernet header (without padding) will already be added
+When the size table is consulted, and you're shaping traffic for the sake of
+another modem/router, an Ethernet header (without padding) will already be added
 to initial packet's length. You should compensate for that by subtracting 14
-from the above overheads in such case. If you're shaping directly on the router
+from the above overheads in this case. If you're shaping directly on the router
 (for example, with speedtouch usb modem) using ppp daemon, you're using raw ip
 interface without underlying layer2, so nothing will be added.
 
@@ -141,10 +141,10 @@ For more thorough explanations, please see \fB[1]\fR and \fB[2]\fR.
 .
 .SH "ETHERNET CARDS CONSIDERATIONS"
 .
-It's often forgotten, that modern network cards (even cheap ones on desktop
+It's often forgotten that modern network cards (even cheap ones on desktop
 motherboards) and/or their drivers often support different offloading
-mechanisms. In context of traffic shaping, 'tso' and 'gso' might cause
-undesirable effects, due to massive tcp segments being considered during
+mechanisms. In the context of traffic shaping, 'tso' and 'gso' might cause
+undesirable effects, due to massive TCP segments being considered during
 traffic shaping (including stab calculations). For slow uplink interfaces,
 it's good to use \fBethtool\fR to turn off offloading features.
 .
-- 
1.8.0.1.g2b06c9a

-- 
		<a href="http://www.catb.org/~esr/">Eric S. Raymond</a>
