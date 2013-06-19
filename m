From: esr@thyrsus.com
Subject: Problems in tc-ematch.8
Date: Tue, 18 Jun 2013 21:02:57 -0400 (EDT)
Message-ID: <20130619010257.75ABE4143C@snark.thyrsus.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8239181010952604908=="
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:54426
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933965Ab3FSBC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 21:02:59 -0400
Received: from [127.0.1.1] (localhost [127.0.0.1])
	by snark.thyrsus.com (Postfix) with ESMTP id 75ABE4143C
	for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 21:02:57 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--===============8239181010952604908==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

This is automatically generated email about markup problems in a man
page for which you appear to be responsible.  If you are not the right
person or list, please tell me so I can correct my database.

See http://catb.org/~esr/doclifter/bugs.html for details on how and
why these patches were generated.  Feel free to email me with any
questions.  Note: These patches do not change the modification date of
any manual page.  You may wish to do that by hand.

I apologize if this message seems spammy or impersonal. The volume of
markup bugs I am tracking is over five hundred - there is no real
alternative to generating bugmail from a database and template.

--
                             Eric S. Raymond

--===============8239181010952604908==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with tc-ematch.8:

Use of low-level troff hackery to set special indents or breaks can't
be translated. The page will have rendering faults in HTML, and
probably also under third-party man page browsers such as Xman,
Rosetta, and the KDE help browser.  This patch eliminates .br, .ta, .ti,
.ce, .in, and \h in favor of requests like .RS/.RE that have
structural translations.

.ti operations are actually no-ops.  Removing them leaves the
page rendering unchanged and simplifies parsing.

--- tc-ematch.8-unpatched	2013-06-14 04:26:20.987408436 -0400
+++ tc-ematch.8	2013-06-14 04:26:37.079408135 -0400
@@ -6,54 +6,43 @@
 .SH SYNOPSIS
 .sp
 .ad l
-.in +8
-.ti -8
 .B "tc filter add .. basic match"
 .RI EXPR
 .B .. flowid ..
 .sp
 
-.ti -8
 .IR EXPR " := " TERM " [ { "
 .B and | or
 }
 .IR EXPR
 ]
 
-.ti -8
 .IR TERM " := [ " \fBnot " ] { " MATCH " | '(' " EXPR " ')' } "
 
-.ti -8
 .IR MATCH " := " module " '(' " ARGS " ')' "
 
-.ti -8
 .IR ARGS " := " ARG1 " " ARG2 " ..
 
 .SH MATCHES
 
 .SS cmp
 Simple comparison ematch: arithmetic compare of packet data to a given value.
-.ti
+
 .IR cmp "( " ALIGN " at " OFFSET " [ " ATTRS " ] { " eq " | " lt " | " gt " } " VALUE " )
 
-.ti
 .IR ALIGN " := { " u8 " | " u16 " | " u32 " } "
 
-.ti
 .IR ATTRS " := [ layer " LAYER " ] [ mask " MASK " ] [ trans ]
 
-.ti
 .IR LAYER " := { " link " | " network " | " transport " | " 0..2 " }
 
 .SS meta
 Metadata ematch
-.ti
+
 .IR meta "( " OBJECT " { " eq " | " lt " |" gt " } " OBJECT " )
 
-.ti
 .IR OBJECT " := { " META_ID " |  " VALUE " }
 
-.ti
 .IR META_ID " := " id " [ shift " SHIFT " ] [ mask " MASK " ]
 
 .TP
@@ -78,35 +67,29 @@
 
 .SS nbyte
 match packet data byte sequence
-.ti
+
 .IR nbyte "( " NEEDLE  " at " OFFSET " [ layer " LAYER " ] )
 
-.ti
 .IR NEEDLE  " := { " string " | " c-escape-sequence "  } "
 
-.ti
 .IR OFFSET  " := " int
 
-.ti
 .IR LAYER " := { " link " | " network " | " transport " | " 0..2 " }
 
 .SS u32
 u32 ematch
-.ti
+
 .IR u32 "( " ALIGN " " VALUE " " MASK " at [ nexthdr+ ] " OFFSET " )
 
-.ti
 .IR ALIGN " := { " u8 " | " u16 " | " u32 " }
 
 .SS ipset
 test packet agains ipset membership
-.ti
+
 .IR ipset "( " SETNAME " " FLAGS " )
 
-.ti
 .IR SETNAME " := " string
 
-.ti
 .IR FLAGS " := { " FLAG " [, " FLAGS "] }
 
 The flag options are the same as those used by the iptables "set" match.

--===============8239181010952604908==--
