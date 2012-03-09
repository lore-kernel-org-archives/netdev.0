From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute: fix tc -iec display of Mibit rates
Date: Fri, 9 Mar 2012 17:09:19 +0100
Message-ID: <20120309160919.GA22767@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas =?iso-8859-1?Q?M=FChlgrabner?= <muehltom@cable.vol.at>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:60242 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932325Ab2CIQGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 11:06:43 -0500
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id 181AAD326
	for <netdev@vger.kernel.org>; Fri,  9 Mar 2012 17:06:40 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by Thomas M=FChlgrabner <muehltom@cable.vol.at>
in http://bugs.debian.org/662979 :

 When showing htb class configuration with "tc -iec class show",
 the output for Mibit is actually the value for bit.
 Example: configure a class with a ceil of 1000Mibit.
 Output states 1048576000 Mibit.

The cause is missing parenteses in the display code of tc....

(Please also note that a lower value of 100Mibit will be displayed
as 102400 Kibit, which I think is kind of ugly.)

Reported-by: Thomas M=FChlgrabner <muehltom@cable.vol.at>
Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 5829d61..36e3c7d 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -203,7 +203,7 @@ void print_rate(char *buf, int len, __u32 rate)
=20
 	if (use_iec) {
 		if (tmp >=3D 1000.0*1024.0*1024.0)
-			snprintf(buf, len, "%.0fMibit", tmp/1024.0*1024.0);
+			snprintf(buf, len, "%.0fMibit", tmp/(1024.0*1024.0));
 		else if (tmp >=3D 1000.0*1024)
 			snprintf(buf, len, "%.0fKibit", tmp/1024);
 		else
