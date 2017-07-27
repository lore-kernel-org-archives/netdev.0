From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/3] ethtool: support for forward error correction mode setting on a link
Date: Thu, 27 Jul 2017 16:47:25 -0700
Message-ID: <1501199248-24695-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, vidya.chowdary@gmail.com,
        dustin@cumulusnetworks.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, kubakici@wp.pl, galp@mellanox.com,
        andrew@lunn.ch, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        jeffrey.t.kirsher@intel.com
To: davem@davemloft.net, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33129 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751697AbdG0Xrg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 19:47:36 -0400
Received: by mail-pg0-f50.google.com with SMTP id c14so11321847pgn.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 16:47:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Forward Error Correction (FEC) modes i.e Base-R
and Reed-Solomon modes are introduced in 25G/40G/100G standards
for providing good BER at high speeds. Various networking devices
which support 25G/40G/100G provides ability to manage supported FEC
modes and the lack of FEC encoding control and reporting today is a
source for interoperability issues for many vendors.
FEC capability as well as specific FEC mode i.e. Base-R
or RS modes can be requested or advertised through bits D44:47 of base link
codeword.

This patch set intends to provide option under ethtool to manage and
report FEC encoding settings for networking devices as per IEEE 802.3
bj, bm and by specs.

v2 :
        - minor patch format fixes and typos pointed out by Andrew
        - there was a pending discussion on the use of 'auto' vs
          'automatic' for fec settings. I have left it as 'auto'
          because in most cases today auto is used in place of
          automatic to represent automatically generated values.
          We use it in other networking config too. I would prefer
          leaving it as auto.

Casey Leedom (2):
  cxgb4: core hardware/firmware support for Forward Error Correction on
    a link
  cxgb4: ethtool forward error correction management support

Vidya Sagar Ravipati (1):
  net: ethtool: add support for forward error correction modes

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  99 ++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 151 ++++++++++++++++-----
 include/linux/ethtool.h                            |   4 +
 include/uapi/linux/ethtool.h                       |  48 ++++++-
 net/core/ethtool.c                                 |  34 +++++
 5 files changed, 300 insertions(+), 36 deletions(-)

-- 
2.1.4
