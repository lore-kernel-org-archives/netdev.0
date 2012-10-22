From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH 0/3] pch_gbe: fix CRC errors and improve speed
Date: Mon, 22 Oct 2012 16:43:22 +0200
Message-ID: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com,
	erwan.velu@zodiacaerospace.com, agospoda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754116Ab2JVOng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 10:43:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series tries to get rid of CRC errors and other instability
caused by wrong RX_FIFO overrun processing. It also cleans the code a bit.

Now (without the patch applied) on high number of incoming packets and/or
stressed system pch_gbe driver reports CRC errors and huge numbers of
RX_FIFO_ERR (overruns). It also sometimes just freezes (caused by not
waiting enough on DMA_RX to stop before issuing a reset on MAC_RX logic).

This patchset removes the unneeded (as per datasheet) MAC_RX reset and
corrects the processing of RX_FIFO_ERR in pch_gbe_napi_poll().

With the patchset applied there are no more CRC errors, sane number of
RX_FIFO_ERR and improved speed/stability. The patchset was tested on
Informix SYS940X and Kontron Tunnel Creek EG20T on 1gbps direct-connected
link and different rx/tx descriptors count.

 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   99 +++++--------------
 1 files changed, 26 insertions(+), 73 deletions(-)
