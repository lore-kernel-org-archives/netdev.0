From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 0/6] bridge: support sending rntl info when we set attributes through sysfs/ioctl
Date: Tue,  5 Apr 2016 11:32:35 +0800
Message-ID: <cover.1459827115.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36201 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbcDEDcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 23:32:47 -0400
Received: by mail-pf0-f194.google.com with SMTP id q129so141386pfb.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 20:32:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is used to support sending rntl info to user in some places,
and ensure that whenever those attributes change internally or from sysfs,
that a netlink notification is sent out to listeners.

It also make some adjustment in bridge sysfs so that we can implement this
easily.

I've done some tests on this patchset, like:
[br_sysfs]
  1. change all the attribute values of br or brif:
  $ echo $value > /sys/class/net/br0/bridge/{*}
  $ echo $value > /sys/class/net/br0/brif/eth1/{*}

  2. meanwhile, on another terminal to observe the msg:
  $ bridge monitor

[br_ioctl]
  1. in bridge-utils package, do some changes in br_set, let brctl command
  use ioctl to set attribute:
         if ((ret = set_sysfs(path, value)) < 0) { -->
         if (1) {

  $ brctl set*

  2. meanwhile, on another terminal to observe the msg:
  $ bridge monitor

This test covers all the attributes that brctl and sysfs support to set.

Xin Long (6):
  bridge: simplify the flush_store by calling store_bridge_parm
  bridge: simplify the forward_delay_store by calling store_bridge_parm
  bridge: simplify the stp_state_store by calling store_bridge_parm
  bridge: a netlink notification should be sent when those attributes
    are changed by br_sysfs_br
  bridge: a netlink notification should be sent when those attributes
    are changed by br_sysfs_if
  bridge: a netlink notification should be sent when those attributes
    are changed by ioctl

 net/bridge/br_ioctl.c    | 40 +++++++++++++----------
 net/bridge/br_sysfs_br.c | 83 +++++++++++++++++++-----------------------------
 net/bridge/br_sysfs_if.c |  5 +--
 net/bridge/br_vlan.c     | 30 +++--------------
 4 files changed, 65 insertions(+), 93 deletions(-)

-- 
2.1.0
