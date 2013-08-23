From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v5 0/5] cpsw: support for control module register
Date: Fri, 23 Aug 2013 20:53:02 +0200
Message-ID: <1377283987-20040-1-git-send-email-zonque@gmail.com>
Cc: bcousson@baylibre.com, nsekhar@ti.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:48767 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756022Ab3HWSxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 14:53:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this is the 5th version of my patch set, the version history is below.

Note that for personal reasons, I won't be able to work on that patch
set for two weeks, starting from a few hours from now. If there are any
more objections or comments, I'll catch up after that period. Or if
anyone wants to make minor changes to my patches and resubmit them,
I'd also be fine with that :)

The compatible discussion is still ongoing, but I'd rather submit what
I got until now, and I'm also still convinced that having
ti,am3352-cpsw is still the best we can do.


Thanks,
Daniel

v4 -> v5:
	* fix return value assignment in devm_ioremap_resource() error
	  paths (reported by Sergei Shtylyov)
	* add more RGMII modes (reported by Mugunthan V N)
	* check for IS_ERR(priv->gmii_sel_reg) in
	  cpsw_set_phy_interface_mode() (reported by Mugunthan V N)
	* move SoC specific definitions to cpsw.h
	* further simplify the probe logic, as devm_ioremap_resource()
	  will check for NULL resources (Sergei Shtylyov)

v3 -> v4:
	* use IS_ERR() to check for failed devm_ioremap_resource()
	  calls (reported by Sergei Shtylyov)

v2 -> v3:
	* swap "ti,am3352-cpsw" and "ti,cpsw" to work around a matching
	  bug (reported by Sekhar)

v1 -> v2:
	* combine devm_request_mem_region() and devm_ioremap() and use
	  devm_ioremap_resource() (reported by Sergei Shtylyov)
	* fix multi-line comment style (reported by Sergei Shtylyov)
	* fix ti,rmii-clock-ext property name (reported by Sekhar)
	* rebased to net-next (reported by Mugunthan V N, David Miller)
	* add a new compatible type, and handle AM33xx specific
	  registers that way (reported by Sekhar)
	* move gmii_sel_reg modifications to the open routine
	  (reported by Mugunthan V N)

Daniel Mack (5):
  net: ethernet: cpsw: switch to devres allocations
  net: ethernet: cpsw: add optional third memory region for CONTROL
    module
  net: ethernet: cpsw: introduce ti,am3352-cpsw compatible string
  net: ethernet: cpsw: add support for hardware interface mode config
  ARM: dts: am33xx: adopt to cpsw changes

 Documentation/devicetree/bindings/net/cpsw.txt |  10 +-
 arch/arm/boot/dts/am33xx.dtsi                  |   5 +-
 drivers/net/ethernet/ti/cpsw.c                 | 248 +++++++++++++------------
 drivers/net/ethernet/ti/cpsw.h                 |   9 +
 4 files changed, 151 insertions(+), 121 deletions(-)

-- 
1.8.3.1
