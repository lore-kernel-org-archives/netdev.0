From: Rob Herring <robh@kernel.org>
Subject: [PATCH 0/4] TI Bluetooth serdev support
Date: Wed,  5 Apr 2017 13:30:01 -0500
Message-ID: <20170405183005.20570-1-robh@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Wei Xu <xuwei5@hisilicon.com>, Eyal Reizer <eyalr@ti.com>,
        Satish Patel <satish.patel@linaro.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
        linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35264 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933265AbdDESaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 14:30:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds serdev support to the HCI LL protocol used on TI BT
modules and enables support on HiKey board with with the WL1835 module.
With this the custom TI UIM daemon and btattach are no longer needed.

The series is available on this git branch[1]. Patch 2 is just clean-up
and can be applied independently. Patch 3 is dependent on the series
"Nokia H4+ support". I'd suggest both series are merged thru the BT tree.

Rob

[1] git://git.kernel.org/pub/scm/linux/kernel/git/robh/linux.git ti-bluetooth

Rob Herring (4):
  dt-bindings: net: Add TI WiLink shared transport binding
  bluetooth: hci_uart: remove unused hci_uart_init_tty
  bluetooth: hci_uart: add LL protocol serdev driver support
  arm64: dts: hikey: add WL1835 Bluetooth device node

 .../devicetree/bindings/net/ti,wilink-st.txt       |  35 +++
 arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts     |   5 +
 drivers/bluetooth/hci_ldisc.c                      |  19 --
 drivers/bluetooth/hci_ll.c                         | 261 ++++++++++++++++++++-
 drivers/bluetooth/hci_uart.h                       |   1 -
 5 files changed, 300 insertions(+), 21 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ti,wilink-st.txt
