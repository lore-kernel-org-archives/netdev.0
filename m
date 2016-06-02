From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/2] Prevent packet reordering on tap/tun interfaces
Date: Wed, 01 Jun 2016 18:17:11 -0700
Message-ID: <20160602010741.9319.56926.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34602 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbcFBBRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 21:17:14 -0400
Received: by mail-pa0-f46.google.com with SMTP id bz2so1253483pad.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 18:17:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is meant to address a recent issue I found with VMs sending
traffic across a network.  Specifically what I found was that the tap
interfaces were spreading single flows across all CPUs on the system due
to the fact that the sending VM was being load balanced across them.  Under
light load this doesn't have much of an impact, however under heavier loads
where the interfaces are already running with Rx cleanup from other flows
on the CPUs I have seen this have a fairly significant impact as we can
avoid any issues due to reordering.  The results can be anywhere from 10 to
30% improvement from what I have seen.

---

Alexander Duyck (2):
      net: Add function to allow configuration of RPS
      tun: Configure Rx queues to default to RPS enabled


 drivers/net/tun.c         |    4 +++-
 include/linux/netdevice.h |    9 ++++++++
 net/core/dev.c            |   51 ++++++++++++++++++++++++++++++++++++++++++++-
 net/core/net-sysfs.c      |   45 +++++++---------------------------------
 4 files changed, 70 insertions(+), 39 deletions(-)
