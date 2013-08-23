From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v4 0/5] cpsw: support for control module register
Date: Fri, 23 Aug 2013 16:16:00 +0200
Message-ID: <1377267365-24057-1-git-send-email-zonque@gmail.com>
Cc: bcousson@baylibre.com, nsekhar@ti.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:48387 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428Ab3HWOQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 10:16:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 drivers/net/ethernet/ti/cpsw.c                 | 254 ++++++++++++++-----------
 drivers/net/ethernet/ti/cpsw.h                 |   2 +
 4 files changed, 159 insertions(+), 112 deletions(-)

-- 
1.8.3.1
