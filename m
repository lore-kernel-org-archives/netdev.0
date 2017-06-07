From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/2] net: emac: fix reset timeout with AR8035 phy
Date: Wed, 7 Jun 2017 16:13:26 +0200
Message-ID: <20170607141326.GB4874@lunn.ch>
References: <eefbc6df06c83b725c60997fc58cf1c0119334a1.1496773338.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        Russell Senior <russell@personaltelco.net>,
        Chris Blake <chrisrblake93@gmail.com>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39722 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750920AbdFGONa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 10:13:30 -0400
Content-Disposition: inline
In-Reply-To: <eefbc6df06c83b725c60997fc58cf1c0119334a1.1496773338.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 07, 2017 at 03:51:15PM +0200, Christian Lamparter wrote:
> This patch fixes a problem where the AR8035 PHY can't be
> detected on an Cisco Meraki MR24, if the ethernet cable is
> not connected on boot.
> 
> Russell Senior provided steps to reproduce the issue:
> |Disconnect ethernet cable, apply power, wait until device has booted,
> |plug in ethernet, check for interfaces, no eth0 is listed.
> |
> |This appears to be a problem during probing of the AR8035 Phy chip.
> |When ethernet has no link, the phy detection fails, and eth0 is not
> |created. Plugging ethernet later has no effect, because there is no
> |interface as far as the kernel is concerned. The relevant part of
> |the boot log looks like this:
> |this is the failing case:
> |
> |[    0.876611] /plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
> |[    0.882532] /plb/opb/ethernet@ef600c00: reset timeout
> |[    0.888546] /plb/opb/ethernet@ef600c00: can't find PHY!
> |and the succeeding case:
> |
> |[    0.876672] /plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
> |[    0.883952] eth0: EMAC-0 /plb/opb/ethernet@ef600c00, MAC 00:01:..
> |[    0.890822] eth0: found Atheros 8035 Gigabit Ethernet PHY (0x01)
> 
> Based on the comment and the commit message of
> commit 23fbb5a87c56 ("emac: Fix EMAC soft reset on 460EX/GT").
> This is because the AR8035 PHY doesn't provide the TX Clock,
> if the ethernet cable is not attached. This causes the reset
> to timeout and the PHY detection code in emac_init_phy() is
> unable to detect the AR8035 PHY. As a result, the emac driver
> bails out early and the user left with no ethernet.
> 
> In order to stay compatible with existing configurations, the driver
> tries the current reset approach at first. Only if the first attempt
> timed out, it does perform one more retry with the clock temporarily
> switched to the internal source for just the duration of the reset.
> 
> LEDE-Bug: #687 <https://bugs.lede-project.org/index.php?do=details&task_id=687>
> 
> Cc: Chris Blake <chrisrblake93@gmail.com>
> Reported-by: Russell Senior <russell@personaltelco.net>
> Fixes: 23fbb5a87c56e98 ("emac: Fix EMAC soft reset on 460EX/GT")
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
