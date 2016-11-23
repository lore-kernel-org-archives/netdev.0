From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH 0/1] NET: usb: cdc_ncm: adding MBIM RESET_FUNCTION request and modifying ncm bind common code
Date: Wed, 23 Nov 2016 13:36:45 +0100
Message-ID: <1479904606-30647-1-git-send-email-dnlplm@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Daniele Palmas <dnlplm@gmail.com>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
        Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34870 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934685AbcKWMhG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 07:37:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some latest QC based modems seem not to properly accept altsetting
toggling in cdc_ncm_bind_common, making them to fail. The workaround
was to introduce an empirically decided pause to avoid the failure.

This patch introduces a different approach: for MBIM devices, instead
of toggling interfaces, the MBIM class-specific request code
RESET_FUNCTION is used in order to reset the function to its initial
state, removing the need for the pause.

Patch has been tested with a few Telit QC and Intel based MBIM modems.

Patch has also been tested with an Intel NCM based device, for
regression checking.

Daniele Palmas (1):
  NET: usb: cdc_ncm: adding MBIM RESET_FUNCTION request and modifying
    ncm bind common code

 drivers/net/usb/cdc_ncm.c    | 39 +++++++++++++++++++++++++++------------
 include/uapi/linux/usb/cdc.h |  1 +
 2 files changed, 28 insertions(+), 12 deletions(-)

-- 
2.7.4
