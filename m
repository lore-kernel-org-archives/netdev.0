From: James Cameron <james.cameron@hp.com>
Subject: [PATCH] sis900 Foxconn 661FX7MI-S PHY support
Date: Wed, 10 May 2006 10:04:50 +1000
Message-ID: <20060510000450.GA5448@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:4771 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1750750AbWEJBdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 21:33:05 -0400
Received: from taynzmail03.nz-tay.cpqcorp.net (relay.jp.compaq.com [16.47.4.103])
	by atlrel8.hp.com (Postfix) with ESMTP id C4BE9360C8
	for <netdev@vger.kernel.org>; Tue,  9 May 2006 21:33:02 -0400 (EDT)
Received: from nestor (unknown [16.145.192.60])
	by taynzmail03.nz-tay.cpqcorp.net (Postfix) with ESMTP id D0D7E4C43
	for <netdev@vger.kernel.org>; Tue,  9 May 2006 21:32:57 -0400 (EDT)
Received: from root by nestor with local (Exim 3.36 #1 (Debian))
	id 1FddZW-0002cr-00
	for <netdev@vger.kernel.org>; Wed, 10 May 2006 11:33:02 +1000
To: venza@brownhat.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch is required to get sis900 ethernet working well on a Foxconn
661FX7MI-S motherboard which uses the SiS 661FX chipset.  The patch adds
an entry to mii_chip_info for the transceiver.  

The PHY ids were found using the sis900_c_122.diff patch from
http://brownhat.org/sis900.html but that patch didn't solve the problem,
because the PHY at address 1 was already being chosen.

Without my patch, when bursts of packets arrive from other hosts on a
LAN, the interface dropped one roughly 10% of the time, causing
retransmits.  There were fifth second pauses in refresh of large xterms,
and it made Netrek suck.  I can provide further test data.

Workaround in lieu of patch is to use mii-tool to advertise
100baseTx-HD, then force renegotiation.

I wasn't able to identify the actual transceiver, so the description
field is a guess.

This patch is similar to Artur Skawina's patch:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114297516729079&w=2

I'm not sure, but I wonder if it means the default behaviour should be
changed, so as to better handle future transceivers.

Diff is against 2.6.16.13.

Signed-off-by: James Cameron <james.cameron@hp.com>

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900_661fx.diff"

--- sis900.c.orig	2006-05-09 10:36:54.000000000 +1000
+++ sis900.c	2006-05-09 12:16:26.000000000 +1000
@@ -127,6 +127,7 @@
 } mii_chip_table[] = {
 	{ "SiS 900 Internal MII PHY", 		0x001d, 0x8000, LAN },
 	{ "SiS 7014 Physical Layer Solution", 	0x0016, 0xf830, LAN },
+	{ "SiS 900 on Foxconn 661 7MI",         0x0143, 0xBC70, LAN },
 	{ "Altimata AC101LF PHY",               0x0022, 0x5520, LAN },
 	{ "AMD 79C901 10BASE-T PHY",  		0x0000, 0x6B70, LAN },
 	{ "AMD 79C901 HomePNA PHY",		0x0000, 0x6B90, HOME},

--fUYQa+Pmc3FrFX/N--
