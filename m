From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 0/8] stmmac: update to Oct 2011 version (v4)
Date: Tue, 18 Oct 2011 12:01:17 +0200
Message-ID: <1318932085-14927-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:44254 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753973Ab1JRKBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 06:01:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches update the driver adding the chained
descriptor mode and some new useful fixes.

I've reviewed some patches after the V1/2/3 and added new ones:

 stmmac: allow mtu bigger than 1500 in case of normal desc (V4)
   |-> removed the useless max_mtu init: Thx Eric's feedback

 stmmac: add CHAINED descriptor mode support (V4)
   |-> removed ifdef in the C and added small routines
	specialised for chained/ring modes. See comment
	within the patch itself. Thx David's feedback.

 stmmac: allow mmc usage only if feature actually available (V4)
   |-> added a check if interface is NULL

 stmmac: limit max_mtu in case of 4KiB and use __netdev_alloc_skb.
  |-> another enhancements proposed by Eric (built on top of the
      V3 patches sent today).

 stmmac: use predefined macros for HW cap register fields (V4)
 stmmac: allow mmc usage only if feature actually available (V4)

Let me know if all is ok.

Regards
Peppe

Giuseppe Cavallaro (6):
  stmmac: protect tx process with lock (V4)
  stmmac: update the driver version and doc (V4)
  stmmac: allow mtu bigger than 1500 in case of normal desc (V4)
  stmmac: allow mmc usage only if feature actually available (V4)
  stmmac: add CHAINED descriptor mode support (V4)
  stmmac: limit max_mtu in case of 4KiB and use __netdev_alloc_skb.

Rayagond Kokatanur (1):
  stmmac: use predefined macros for HW cap register fields (V4)

Srinivas Kandagatla (1):
  stmmac: Stop advertising 1000Base capabilties for non GMII iface
    (V4).

 Documentation/networking/stmmac.txt                |   11 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   18 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |  137 ++++++++++++
 drivers/net/ethernet/stmicro/stmmac/common.h       |   43 ++++
 drivers/net/ethernet/stmicro/stmmac/descs_com.h    |  126 +++++++++++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   22 +--
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   14 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |  126 +++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    5 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   24 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  223 ++++++++++----------
 12 files changed, 610 insertions(+), 141 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/chain_mode.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/descs_com.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/ring_mode.c

-- 
1.7.4.4
