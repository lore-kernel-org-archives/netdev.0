From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: [PATCH]  New driver "sfc" for Solarstorm SFC4000 controller - 4th
 attempt
Date: Thu, 10 Jan 2008 18:29:53 +0000
Message-ID: <47866421.7020500@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: spope@solarflare.com, linux-net-drivers@solarflare.com
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:46163 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755361AbYAJSfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 13:35:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmission of a new driver for Solarflare network controllers.

The driver supports several types of PHY (10Gbase-T, XFP, CX4) on six
different 10G and 1G boards.

Hardware based on this network controller is now available from SMC as
part numbers SMC10GPCIe-XFP and SMC10GPCIe-10BT.

The previous thread was:
  http://marc.info/?l=linux-netdev&m=119825632209357&w=2


Thanks to the people who looked at the previous patches. We have addressed
the following from comments received after the 3rd submission:
 - Kerneldoc style comment
 - Kconfig changes
 - Reduced size slightly

I am also sending a request to linux-mtd@lists.infradead.org for review of
the MTD part of the driver.


Previous reviewers have noted that the driver is quite large (but it
would not be the largest network driver by source or compiled module
size). I think it is a reasonable size for a driver that supports a
fully featured NIC, across a range of MACs, PHYs and silicon
revisions.

One aspect that is worth mentioning is that the NIC has no firmware.
A benefit is no dreaded binary blob!  A downside is that more support
code is needed but this tends to be around initialisation and is
readable commented C.

To give a small break down of the sizes of the different driver parts
                                 (wc output)
 Core control/datapath         | 5001  16405 139467  = efx.c rx.c tx.c
 Controller HW support         | 3653  11823 107554  = falcon.c
 HW defs                       | 1588   4838  47050  = falcon_hwdefs.h
 board support                 | 1848   7105  52455
 MAC support                   | 1623   4977  51007
 PHY support                   | 2196   7904  67711
 Headers                       | 4565  20645 162402
 Self test code                |  863   3088  24981
 Ethtool support               |  751   2144  22845
 MTD code (separate module)    | 1021   3200  26944
 Debugfs Code (KConfig option) |  863   2543  24896


Are there further review comments that we need to address before it can be
merged?


The patch (against net-2.6.25) is at:
     https://support.solarflare.com/netdev/4/net-2.6.25-sfc-2.2.0038.patch

The new files may also be downloaded as a tarball:
     https://support.solarflare.com/netdev/4/net-2.6.25-sfc-2.2.0038.tgz

And for verification there is:
     https://support.solarflare.com/netdev/4/MD5SUMS

Regards

-- 
Rob Stonehouse
