From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 0/3] drivers: net: xgene: Fix backward compatibility of newer firmware with older kernel
Date: Tue,  3 Mar 2015 11:39:38 -0800
Message-ID: <1425411581-25463-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, mlangsdo@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og114.obsmtp.com ([64.18.0.28]:59064 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754190AbbCCTfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 14:35:32 -0500
Received: by padfa1 with SMTP id fa1so20445634pad.3
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 11:35:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 3.17 driver supports only RGMII ethernet interface.
Since the Tianocore DT contains same compatibility string for RGMII,
SGMII based 1G and XFI based 10G interfaces, crash happens when probe called
on SGMII based 1G and XFI based 10G interface.

This patch fixes the backward compatibility of the older driver with the
newer firmware by making the binding unique so that the older driver won't
recognize the non-supported interfaces.

v2: Address comments from v1
* updated cover letter subject line with net: xgene
* Documentation: formatted compatible string values as list

v1:
* Initial version
---

Iyappan Subramanian (3):
  Documentation: dts: Update compatible field description for APM X-Gene
  dtb: change binding name to match with newer firmware DT
  drivers: net: xgene: fix new firmware backward compatibility with
    older driver

 Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 5 ++++-
 arch/arm64/boot/dts/apm/apm-storm.dtsi                   | 4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         | 4 ++++
 3 files changed, 10 insertions(+), 3 deletions(-)

-- 
1.9.1
