From: =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
Subject: [PATCH v2 0/2] Fixes for sierra_net driver
Date: Tue, 7 Feb 2017 03:33:15 +0100
Message-ID: <dc876555b6a347ce9df40d98c4c489a5@rwthex-w2-b.rwth-ad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
To: <linux-usb@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-out-2.rwth-aachen.de ([134.130.5.187]:56252 "EHLO
        mx-out-2.rwth-aachen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBGCd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 21:33:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to initiate a dual-stack (ipv4v6) connection, a MC7710, FW
version SWI9200X_03.05.24.00ap answers with an unsupported LSI. Add support
for this LSI.
Also the link_type should be ignored when going idle, otherwise the modem
is stuck in a bad link state.
Tested on MC7710, T-Mobile DE, APN internet.telekom, IPv4v6 PDP type. Both
IPv4 and IPv6 connections work.

v2: Do not overwrite protocol field in rx_fixup

Stefan Brüns (2):
  sierra_net: Add support for IPv6 and Dual-Stack Link Sense Indications
  sierra_net: Skip validating irrelevant fields for IDLE LSIs

 drivers/net/usb/sierra_net.c | 110 ++++++++++++++++++++++++++++---------------
 1 file changed, 71 insertions(+), 39 deletions(-)

-- 
2.11.0
