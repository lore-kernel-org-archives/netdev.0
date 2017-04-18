From: Daniel Walker <danielwa@cisco.com>
Subject: Marvell phy errata origins?
Date: Tue, 18 Apr 2017 06:16:33 -0700
Message-ID: <59691a35-a89c-f9ca-c7b0-73134a737f4c@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andy Fleming <afleming@freescale.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        HEMANT RAMDASI <hramdasi@cisco.com>,
        "Julius Hemanth Pitti -X (jpitti - MONTA VISTA SOFTWARE INC at Cisco)"
        <jpitti@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-4.cisco.com ([173.37.142.91]:29751 "EHLO
        alln-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751467AbdDRN0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 09:26:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Cisco is using a Marvell 88E1112 phy. It seems to be fairly similar to 
the 88E1111 which Harini added a fix for. In Harini's commit message for ,

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/drivers/net/phy/marvell.c?id=3ec0a0f10ceb

"This function has a sequence accessing Page 5 and Register 31, both of 
which are not defined or reserved for this PHY"

For the 88E1112 we see that these are "Factory Test Modes" which the 
contents of are not documented. They aren't really "not defied", and 
aren't really "reserved" .. Marvell support claims they don't support 
these drivers, and Freescale seems to be adding these drivers, and the 
line we are looking at.

We had some issues with our PHY which were corrected with the same patch 
Harini used but modified for the M88E1112. We're trying to get to the 
bottom of where this code came from and what it was suppose to be doing.

Here are the problem lines where were removed,

drivers/net/phy/marvell.c:marvell_config_aneg()

  266         err = phy_write(phydev, 0x1d, 0x1f);
  267         if (err < 0)
  268                 return err;
  269
  270         err = phy_write(phydev, 0x1e, 0x200c);
  271         if (err < 0)
  272                 return err;
  273
  274         err = phy_write(phydev, 0x1d, 0x5);
  275         if (err < 0)
  276                 return err;
  277
  278         err = phy_write(phydev, 0x1e, 0);
  279         if (err < 0)
  280                 return err;
  281
  282         err = phy_write(phydev, 0x1e, 0x100);
  283         if (err < 0)
  284                 return err;

Does anyone have any clues as to why this was added?

Thanks,

Daniel
