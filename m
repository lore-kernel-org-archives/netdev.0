From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [RFC PATCH 0/2] net: arc_emac: fix tx issues
Date: Sun, 20 Jul 2014 17:44:56 +0200
Message-ID: <1405871098-5663-1-git-send-email-b.galvani@gmail.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Max Schwarz <max.schwarz@online.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Thierry Reding <thierry.reding@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:65154 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbaGTPrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 11:47:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've found a strange behaviour of the ARC EMAC driver while doing some
tests on a Rockchip based Radxa Rock board and the following patches
are a try to solve the problem. I'm not sure if they are correct or if
there's a better way to do the same thing, so I'd like to receive some
feedback on this.

The problem I'm facing is that the transmission of a UDP stream from
the device stops immediately with the socket send buffer full and this
seems due to the current implementation of tx reclaiming.

With the two patches below, which do the following:

 - enable tx interrupts, which are used to trigger a napi poll and
   thus a clean of tx ring
 - fix a possible race between xmit and tx clean

everything seems to work properly.

Any comments are welcome,
Beniamino

Beniamino Galvani (2):
  net: arc_emac: enable tx interrupts
  net: arc_emac: prevent reuse of unreclaimed tx descriptors

 drivers/net/ethernet/arc/emac_main.c |   56 +++++++++++++++++++++++-----------
 1 file changed, 38 insertions(+), 18 deletions(-)

-- 
1.7.10.4
