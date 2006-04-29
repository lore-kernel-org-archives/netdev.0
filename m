From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 0/3] Eleminate HZ from AX.25, NETROM and ROSE kernel interfaces
Date: Sat, 29 Apr 2006 15:03:27 +0100
Message-ID: <20060429140327.GA2173@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:59333 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133564AbWD2Sqk (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Sat, 29 Apr 2006 19:46:40 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AX.25, NET/ROM and ROSE unfortunately still use jiffies as the unit of
time for all their timeouts that can be configured through sysctl and
it's procfs equivalents.  This did result in a change of these kernel
interfaces going from Linux 2.4 to 2.6 for anybody who was unlucky enough
to use an affected platform such as i386 and most MIPS but not Alpha.
Making matters worse, it required the sysadmin of the particular system
to know the timing value making it very, very broken inteface design.
The timer interrupt frequency recently becoming configurable made things
even worse, so this really needed to be fixed.  The following series
of patches contains three patches, one for each of the three packet radio
protocols to switch the unit used by the sysadmin to miliseconds thus
resulting in a deterministic interface.

  Ralf
