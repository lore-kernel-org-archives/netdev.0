From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] iproute2: tc.8: update UNITS section.
Date: Tue, 28 Aug 2012 13:38:57 +0800
Message-ID: <1346132337-21325-1-git-send-email-lw@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Li Wei <lw@cn.fujitsu.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:6329 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751009Ab2H1Fkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 01:40:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- rename section UNITS to PARAMETERS.
- break section PARAMETERS down to four subsections to cover the
  common used parameter types(RATES, TIMES, SIZES, VALUES).
- add some explaination for IEC units in RATES.
- point out the max value we can set for RATES, TIMES and SIZES.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 man/man8/tc.8 |  111 +++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 85 insertions(+), 26 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 98fbfcd..44d644a 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -257,19 +257,20 @@ qdiscs applies.
 FILTERS
 Filters have a three part ID, which is only needed when using a hashed
 filter hierarchy.
-.SH UNITS
-All parameters accept a floating point number, possibly followed by a unit.
-.P
-Bandwidths or rates can be specified in:
-.TP
-bps
-Bytes per second
+
+.SH PARAMETERS
+These following parameters are widely used in TC, for other parameters,
+see the man page for individual qdiscs.
+
 .TP
-kbps
-Kilobytes per second
+RATES
+Bandwidths or rates.
+These parameters accept a floating point number, possibly followed by
+a unit(both SI and IEC units supported).
+.RS
 .TP
-mbps
-Megabytes per second
+bit or a bare number
+Bits per second
 .TP
 kbit
 Kilobits per second
@@ -277,27 +278,41 @@ Kilobits per second
 mbit
 Megabits per second
 .TP
-bit or a bare number
-Bits per second
-.P
-Amounts of data can be specified in:
+gbit
+Gegabits per second
 .TP
-kb or k
-Kilobytes
+tbit
+Terabits per second
 .TP
-mb or m
-Megabytes
+bps
+Bytes per second
 .TP
-mbit
-Megabits
+kbps
+Kilobytes per second
 .TP
-kbit
-Kilobits
+mbps
+Megabytes per second
 .TP
-b or a bare number
-Bytes.
+gbps
+Gigabytes per second
+.TP
+tbps
+Terabytes per second
+
+.P
+To specified in IEC units, just replace the SI prefix(k-, m-, g-, t-) with
+IEC prefix(ki-, mi-, gi- and ti-) respectively.
+
 .P
-Lengths of time can be specified in:
+TC store rates as a __u32 integer in bps internally,
+so we can specify a max rate of UINT32_MAX bps.
+.RE
+
+.TP
+TIMES
+Length of time. Can be specified as a float pointing number 
+followed by an optional unit:
+.RS
 .TP
 s, sec or secs
 Whole seconds
@@ -308,6 +323,50 @@ Milliseconds
 us, usec, usecs or a bare number
 Microseconds.
 
+.P
+TC defined it's own time unit(equals to microsecond) and store time values
+as __u32 integer, thus we can specify a max time value of UINT32_MAX usecs.
+.RE
+
+.TP
+SIZES
+Amounts of data. Can be specified as a float pointing number 
+followed by an optional unit:
+.RS
+.TP
+b or a bare number
+Bytes.
+.TP
+kbit
+Kilobites
+.TP
+kb or k
+Kilobytes
+.TP
+mbit
+Megabits
+.TP
+mb or m
+Megabytes
+.TP
+gbit
+Gigabites
+.TP
+gb or g
+Gigabytes
+
+.P
+TC store sizes internally as __u32 integer in byte, so we can specify
+a max size of UINT32_MAX bytes.
+.RE
+
+.TP
+VALUES
+Other values without a unit.
+These parameters read as decimal by default, but you can
+indicate TC to read them as octal and hexadecimal by adding a '0'
+or '0x' prefix respectively.
+
 .SH TC COMMANDS
 The following commands are available for qdiscs, classes and filter:
 .TP
-- 
1.7.10.1
