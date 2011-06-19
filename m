From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/7] net: fixup time stamping batch #1
Date: Sun, 19 Jun 2011 15:31:38 +0200
Message-ID: <cover.1308489767.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55555 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab1FSNbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 09:31:43 -0400
Received: by fxm17 with SMTP id 17so477619fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 06:31:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Eric Dumazet helpfully pointed out, the placing the transmit time
stamp hook after giving the skb to hardware races with the completion
ISR, for those drivers which free the buffer in the ISR.

This series fixes up the first batch of time stamping hook patches.

Richard Cochran (7):
  net: correct comment on where to place transmit time stamp hook.
  fec: fix race in transmit time stamping.
  tg3: fix race in transmit time stamping.
  r6040: fix race in transmit time stamping.
  stmmac: fix race in transmit time stamping.
  smsc9420: fix race in transmit time stamping.
  davinci_emac: fix race in transmit time stamping.

 drivers/net/davinci_emac.c       |    3 ++-
 drivers/net/fec.c                |    4 ++--
 drivers/net/r6040.c              |    5 +++--
 drivers/net/smsc9420.c           |    4 ++--
 drivers/net/stmmac/stmmac_main.c |    4 ++--
 drivers/net/tg3.c                |    4 ++--
 include/linux/skbuff.h           |    3 +--
 7 files changed, 14 insertions(+), 13 deletions(-)

