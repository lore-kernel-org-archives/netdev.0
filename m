From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: [PATCH] iptables: document IPv6 TOS mangling bug in old Linux
 kernels
Date: Fri, 17 Jun 2011 10:14:06 +0900
Message-ID: <1308273246.8612.3.camel@nexus.oss.ntt.co.jp>
References: <1307320871-31770-1-git-send-email-pablo@netfilter.org>
	 <1307320871-31770-2-git-send-email-pablo@netfilter.org>
	 <BANLkTikAs7fN2JQJTUwQHAYPPGMf8i9uEA@mail.gmail.com>
	 <alpine.LNX.2.01.1106061618370.17430@frira.zrqbmnf.qr>
	 <1308213411.4062.22.camel@nausicaa>
	 <alpine.LNX.2.01.1106161705300.10015@frira.zrqbmnf.qr>
	 <4DFA1DFC.3000804@trash.net>  <1308273097.8612.1.camel@nexus.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maciej <zenczykowski@gmail.com>,
	Pablo Neira Aysuo <pablo@netfilter.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:58460 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710Ab1FQBOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 21:14:07 -0400
In-Reply-To: <1308273097.8612.1.camel@nexus.oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Linux kernels up to and including 2.6.38, with the exception of longterm
releases 2.6.32.42 (or later) and 2.6.33.15 (or later), there is a bug (*) whereby
IPv6 TOS mangling does not behave as documented and differs from the IPv4
version. The TOS mask indicates the bits one wants to zero out, so it needs to
be inverted before applying it to the original TOS field. However, the
aformentioned kernels forgo the inversion which breaks --set-tos and its
mnemonics.

(*) Fixed by upstream commit:
    1ed2f73d90fb49bcf5704aee7e9084adb882bfc5 (netfilter: IPv6: fix DSCP mangle code)

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp iptables-1.4.11.1-orig/extensions/libxt_TOS.man iptables-1.4.11.1/extensions/libxt_TOS.man
--- iptables-1.4.11.1-orig/extensions/libxt_TOS.man	2011-06-08 22:26:17.000000000 +0900
+++ iptables-1.4.11.1/extensions/libxt_TOS.man	2011-06-17 10:07:58.873127519 +0900
@@ -4,24 +4,33 @@ shares the same bits as DSCP and ECN. Th
 \fBmangle\fP table.
 .TP
 \fB\-\-set\-tos\fP \fIvalue\fP[\fB/\fP\fImask\fP]
-Zeroes out the bits given by \fImask\fP and XORs \fIvalue\fP into the
-TOS/Priority field. If \fImask\fP is omitted, 0xFF is assumed.
+Zeroes out the bits given by \fImask\fP (see NOTE below) and XORs \fIvalue\fP
+into the TOS/Priority field. If \fImask\fP is omitted, 0xFF is assumed.
 .TP
 \fB\-\-set\-tos\fP \fIsymbol\fP
 You can specify a symbolic name when using the TOS target for IPv4. It implies
-a mask of 0xFF. The list of recognized TOS names can be obtained by calling
-iptables with \fB\-j TOS \-h\fP.
+a mask of 0xFF (see NOTE below). The list of recognized TOS names can be
+obtained by calling iptables with \fB\-j TOS \-h\fP.
 .PP
 The following mnemonics are available:
 .TP
 \fB\-\-and\-tos\fP \fIbits\fP
 Binary AND the TOS value with \fIbits\fP. (Mnemonic for \fB\-\-set\-tos
-0/\fP\fIinvbits\fP, where \fIinvbits\fP is the binary negation of \fIbits\fP.)
+0/\fP\fIinvbits\fP, where \fIinvbits\fP is the binary negation of \fIbits\fP.
+See NOTE below.)
 .TP
 \fB\-\-or\-tos\fP \fIbits\fP
 Binary OR the TOS value with \fIbits\fP. (Mnemonic for \fB\-\-set\-tos\fP
-\fIbits\fP\fB/\fP\fIbits\fP.)
+\fIbits\fP\fB/\fP\fIbits\fP. See NOTE below.)
 .TP
 \fB\-\-xor\-tos\fP \fIbits\fP
 Binary XOR the TOS value with \fIbits\fP. (Mnemonic for \fB\-\-set\-tos\fP
-\fIbits\fP\fB/0\fP.)
+\fIbits\fP\fB/0\fP. See NOTE below.)
+.PP
+NOTE: In Linux kernels up to and including 2.6.38, with the exception of
+longterm releases 2.6.32.42 (or later) and 2.6.33.15 (or later), there is a bug
+whereby IPv6 TOS mangling does not behave as documented and differs from the
+IPv4 version. The TOS mask indicates the bits one wants to zero out, so it needs
+to be inverted before applying it to the original TOS field. However, the
+aformentioned kernels forgo the inversion which breaks --set-tos and its
+mnemonics.


