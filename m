From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 0/3] Fix backward compatibility of newer firmware with older kernel
Date: Fri, 27 Feb 2015 12:08:27 -0800
Message-ID: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, mlangsdo@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og114.obsmtp.com ([64.18.0.28]:59807 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754752AbbB0UEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:04:24 -0500
Received: by pabli10 with SMTP id li10so9144721pab.3
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 12:04:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 3.17 driver supports only RGMII ethernet interface.
Since the Tianocore DT contains same compatibility string for RGMII,
SGMII based 1G and XFI based 10G interfaces, crash happens when probe called
on SGMII based 1G and XFI based 10G interface.

This patch fixes the backward compatibility of the older driver with the
newer firmware by making the binding unique so that the older driver won't
recognize the non-supported interfaces.

---

Iyappan Subramanian (3):
  Documentation: dts: Update compatible field description for APM X-Gene
  dtb: change binding name to match with newer firmware DT
  drivers: net: xgene: fix new firmware backward compatibility with
    older driver

 Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 3 ++-
 arch/arm64/boot/dts/apm/apm-storm.dtsi                   | 4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         | 4 ++++
 3 files changed, 8 insertions(+), 3 deletions(-)

-- 
1.9.1
