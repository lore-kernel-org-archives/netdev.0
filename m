From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 0/2] sfc: enable 4-tuple UDP RSS hashing
Date: Tue, 27 Sep 2016 17:32:19 +0100
Message-ID: <cc07d60a-189c-8475-ecb3-b612ff13bd5a@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <bkenward@solarflare.com>
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:8753 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752565AbcI0Qcy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:32:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EF10 based NICs have configurable RSS hash fields, and can be made to take the
ports into the hash on UDP (they already do so for TCP).  This patch series
enables this, in order to improve spreading of UDP traffic.
Patch 2/2, which updates the ETHTOOL_GRXFH handling to report the new RSS hash
settings, uses a somewhat unorthodox construct to control fall-through flow in
a switch statement - is this acceptable style?

Edward Cree (2):
  sfc: enable 4-tuple RSS hashing for UDP
  sfc: report 4-tuple UDP hashing to ethtool, if it's enabled

 drivers/net/ethernet/sfc/ef10.c       | 84 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ethtool.c    | 14 ++++--
 drivers/net/ethernet/sfc/net_driver.h |  2 +
 3 files changed, 96 insertions(+), 4 deletions(-)
