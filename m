From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 (RGMII Timing)
Date: Mon, 5 Nov 2007 12:15:30 -0600
Message-ID: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, paulus@samba.org
To: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:33250 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303AbXKESQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 13:16:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

the following patches fix RGMII timing for rev. 2.1 of the mpc8360,
according to erratum #2 (erratum text included below).  Basically the
most intrusive part is the addition of two new RGMII Internal Delay
modes; one for TX delay only, and the other for RX delay only (i.e, not
both at the same time).

Please review, and since this affects both netdev and powerpc trees,
one maintainer should ack them for the other to push upstream (i.e,
Kumar acks them, and Leo picks them up to go through netdev or the
other way around; either way is fine with me).  I'm hoping they're
trivial enough to go in 2.6.24.

Depending on how the review goes, a follow-on patch to u-boot will be
sent out that fixes up the phy-connection-type in the device tree (from
"rgmii-id" to "rgmii-rxid" iff on mpc8360rev2.1).

Thanks,

Kim

mpc8360 rev 2.1 erratum #2:
-----------
Recommended AC timings for chip 8360Rev2.1 UCC ETH RGMII  when working
with Rev Pilot MDS for proper RGMII operation:

IMMR_BASE + 0x14A8[4:5] = 11 (clk delay for UCC 2)
IMMR_BASE + 0x14A8[18:19] = 11 (clk delay for UCC 1)
IMMR_BASE + 0x14AC[20:27] = 10101010 (data delay for both UCC's)

The Phy (Marvell 88e1111) should be configured NOT to work with RGMII
delay for TxD.
