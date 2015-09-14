From: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
Subject: [PATCH v7 0/3] can: Allwinner A10/A20 CAN Controller support - Summary
Date: Tue, 15 Sep 2015 01:17:09 +0200
Message-ID: <1442272632-20251-1-git-send-email-info@gerhard-bertelsmann.de>
Cc: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
To: wg@grandegger.com, mkl@pengutronix.de,
	maxime.ripard@free-electrons.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

please find attached the next version of my patch set. I have 
taken all remarks from Marc into the new version

Please review, test and report bugs if exists.

The patchset applies to all recent Kernel versions (4.3-rc, 4.2, next etc.).

[PATCH v7 1/3] Device Tree Binding Documentation
[PATCH v7 2/3] Defconfigs
[PATCH v7 3/3] Kernel Module

History:
    V7: set_normal_mode: stripped (code inserted in can_stop)
        set_reset_mode: stripped (code inserted in can_start)
        sunxi_can_start: reworked
        sunxi_can_stop: function added
	sunxi_can_err: don't skip if skb alloc fails
	sunxican_bittiming_const: use netdev_dbg instead of netdev_info
        sunxican_probe: CAN_CTRLMODE_PRESUME_ACK

    v6: renamed the driver to sun4i as suggested by Maxime Ripard
        removed module version
        removed suspend and resume
        moved clk enable from can_start into open / should be balanced
          between enabling and disabling now
        freeing resources on error
        
    v5: fix license
        modify prefix to mode select defines
        enable and disable clock in sunxican_get_berr_counter
        delete set_normal_mode at the end of sunxi_can_start
        removed sunxican_id_table
        use devm_clk_get instead of clk_get
        use devm_ioremap_resource to simplify probe and remove
        make set-normal-mode and set-reset-mode more readable
        
    v4: defines prefixed with SUNXI_
        sunxi_can_write_cmdreg tweaked
        loops in set_xxx_mode reworked
        add return value to set_xxx_mode
        sunxican_start_xmit reworked
        struct platform_driver stripped
        moved set_bittiming into open
        moved clock start into open
        add clock stop to close
        suspend reworked
        resume reworked
        fixed double counting bug

    v3: changed error state change handling (thx Andri for the hint)
        use bittiming function correct (no need to call it)
        strip down priv (suggested by Marc)
        scripts/checkpatch.pl-> no matches anymore
        sparse -> no errors or warnings anymore
    v2: cleaning
    v1: initial

Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
---

 .../devicetree/bindings/net/can/sun4i_can.txt      |  38 +
 arch/arm/configs/multi_v7_defconfig                |   1 +
 arch/arm/configs/sunxi_defconfig                   |   2 +
 drivers/net/can/Kconfig                            |  10 +
 drivers/net/can/Makefile                           |   1 +
 drivers/net/can/sun4i_can.c                        | 857 +++++++++++++++++++++
 6 files changed, 909 insertions(+)

