From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: [PATCH] phylib: phy_ethtool_{sset,gset} -- check phydev for NULL
Date: Thu, 10 May 2007 21:29:51 +0400
Message-ID: <8496f91a0705101029g794ee4a7t1c6a34ad13444c49@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:41499 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755073AbXEJR3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 13:29:52 -0400
Received: by py-out-1112.google.com with SMTP id a29so546637pyi
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 10:29:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Good Day!

The command 'brctl addbr br0 eth0' brings the kernel oops if the eth0
has PHY, but the phydev is NULL (for ex., ifconfig eth0 0.0.0.0 was
not issued firstly)

Call Trace:
[C02CFBD0] [7FFFFFFF] 0x7fffffff (unreliable)
[C02CFBE0] [C0109634] dev_ethtool+0x1b0/0xfac
[C02CFCD0] [C0155EF0] port_cost+0x5c/0x130
[C02CFD40] [C01561FC] br_add_if+0x17c/0x308
[C02CFD70] [C01569E0] add_del_if+0x70/0xa0
[C02CFD90] [C0156A58] br_dev_ioctl+0x48/0x9fc
[C02CFE10] [C0106FCC] dev_ifsioc+0x144/0x3ac
[C02CFE30] [C01080D8] dev_ioctl+0x3b8/0x4c8
[C02CFEB0] [C00F9BC0] sock_ioctl+0x78/0x260
[C02CFED0] [C006889C] do_ioctl+0x38/0x84
[C02CFEE0] [C006896C] vfs_ioctl+0x84/0x3d8
[C02CFF10] [C0068D00] sys_ioctl+0x40/0x74
[C02CFF40] [C000EF48] ret_from_syscall+0x0/0x38

The following patch fixes the problem.

Signed-off-by: Matvejchikov Ilya <matvejchikov <at> gmail.com>
---

diff -purN linux-2.6.21-clean/drivers/net/phy/phy.c
linux-2.6.21/drivers/net/phy/phy.c
--- linux-2.6.21-clean/drivers/net/phy/phy.c    2007-04-26
07:08:32.000000000 +0400
+++ linux-2.6.21/drivers/net/phy/phy.c  2007-05-04 08:22:01.000000000 +0400
@@ -245,6 +245,9 @@ EXPORT_SYMBOL(phy_sanitize_settings);
 */
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
+       if (unlikely(NULL == phydev))
+               return -EINVAL;
+
       if (cmd->phy_address != phydev->addr)
               return -EINVAL;

@@ -289,6 +292,9 @@ EXPORT_SYMBOL(phy_ethtool_sset);

 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
+       if (unlikely(NULL == phydev))
+               return -EINVAL;
+
       cmd->supported = phydev->supported;

       cmd->advertising = phydev->advertising;
