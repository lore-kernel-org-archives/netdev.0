From: Paolo Pisati <p.pisati@gmail.com>
Subject: [PATCH 0/6] kernel parameters: introduce "macaddr" to set mac address
Date: Tue, 23 Oct 2012 19:15:27 +0200
Message-ID: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35211 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756995Ab2JWRPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:15:46 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so3927995wib.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:15:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the past drivers grew mechanism to set their own mac address at boot time
via (usually) a module parameter. Unfortunately every single driver had its
own naming/implementation and it soon became clear that a generic
mechanism was needed.

Introduce "macaddr=", a new kernel parameter to set MAC address using
netdevice ops (and hence being hardware independent).

After 0001 is committed, we can garbage collect some custom driver code
that does the same functionality (0002-0006).

I couldn't find the maintainers of ksz884x, sunhme and fec, so pleace cc:
them if you know who they are.

Paolo Pisati (6):
  macaddr kernel bootargs implementation
  stmmac: remove mac address handling as a module parameter
  ksz884x: remove mac address handling as a module parameter
  greth: remove mac address handling as a module parameter
  sunhme: remove mac address handling as a module parameter
  fec: remove mac address handling as a module parameter

 Documentation/kernel-parameters.txt               |    4 +
 drivers/net/ethernet/aeroflex/greth.c             |   36 +++-----
 drivers/net/ethernet/freescale/fec.c              |   27 ++----
 drivers/net/ethernet/micrel/ksz884x.c             |   57 ------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   13 ---
 drivers/net/ethernet/sun/sunhme.c                 |   69 ++++----------
 net/core/dev.c                                    |  101 +++++++++++++++++++++
 7 files changed, 140 insertions(+), 167 deletions(-)

-- 
1.7.9.5
