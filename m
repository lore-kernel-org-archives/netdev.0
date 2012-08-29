From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH v2] iproute2: tc.8: update UNITS section.
Date: Wed, 29 Aug 2012 14:41:56 +0800
Message-ID: <1346222516-14814-1-git-send-email-lw@cn.fujitsu.com>
References: <1346132337-21325-1-git-send-email-lw@cn.fujitsu.com>
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	Li Wei <lw@cn.fujitsu.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15170 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751160Ab2H2GnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2012 02:43:00 -0400
In-Reply-To: <1346132337-21325-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- rename section UNITS to PARAMETERS.
- break section PARAMETERS down to four subsections to cover the
  common used parameter types(RATES, TIMES, SIZES, VALUES).
- add some explaination for IEC units in RATES.
- point out the max value we can set for RATES, TIMES and SIZES.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
Changes from v1:
- fix some syntax and spelling errors. Thanks Ben!

 man/man8/tc.8 |  112 +++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 86 insertions(+), 26 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 98fbfcd..f81d46f 100644
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
+The following parameters are widely used in TC. For other parameters,
+see the man pages for individual qdiscs.
+
 .TP
-kbps
-Kilobytes per second
+RATES
+Bandwidths or rates.
+These parameters accept a floating point number, possibly followed by
+a unit (both SI and IEC units supported).
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
+Gigabits per second
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
+To specify in IEC units, replace the SI prefix (k-, m-, g-, t-) with
+IEC prefix (ki-, mi-, gi- and ti-) respectively.
+
 .P
-Lengths of time can be specified in:
+TC store rates as a 32-bit unsigned integer in bps internally,
+so we can specify a max rate of 4294967295 bps.
+.RE
+
+.TP
+TIMES
+Length of time. Can be specified as a floating point number 
+followed by an optional unit:
+.RS
 .TP
 s, sec or secs
 Whole seconds
@@ -308,6 +323,51 @@ Milliseconds
 us, usec, usecs or a bare number
 Microseconds.
 
+.P
+TC defined its own time unit (equal to microsecond) and stores
+time values as 32-bit unsigned integer, thus we can specify a max time value
+of 4294967295 usecs.
+.RE
+
+.TP
+SIZES
+Amounts of data. Can be specified as a floating point number 
+followed by an optional unit:
+.RS
+.TP
+b or a bare number
+Bytes.
+.TP
+kbit
+Kilobits
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
+Gigabits
+.TP
+gb or g
+Gigabytes
+
+.P
+TC stores sizes internally as 32-bit unsigned integer in byte,
+so we can specify a max size of 4294967295 bytes.
+.RE
+
+.TP
+VALUES
+Other values without a unit.
+These parameters are interpreted as decimal by default, but you can
+indicate TC to interpret them as octal and hexadecimal by adding a '0'
+or '0x' prefix respectively.
+
 .SH TC COMMANDS
 The following commands are available for qdiscs, classes and filter:
 .TP
-- 
1.7.10.1
