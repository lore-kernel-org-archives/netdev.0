From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/14] rocker: add support for multiple worlds
Date: Sun,  4 Oct 2015 23:25:35 +0200
Message-ID: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34455 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbbJDVZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 17:25:53 -0400
Received: by wicfx3 with SMTP id fx3so94826926wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 14:25:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset allows new rocker worlds to be easily added in future (like eBPF
based one I have been working on). The main part of the patchset is the OF-DPA
carve-out. It resuts in OF-DPA specific file. Clean cut.
The user is able to change rocker port world/mode using rtnl.

Jiri Pirko (14):
  rocker: remove unused rocker_port param from alloc funcs and shorten
    their names
  rocker: rename rocker.h to rocker_hw.h
  rocker: rename rocker.c to rocker_main.c
  rocker: push tlv processing into separate files
  rocker: implement set settings mode command
  rocker: introduce worlds infrastructure
  rocker: introduce OF-DPA world skeleton
  rocker: set default world on port probe and clean world on remove
  rocker: add rtnl ops for port mode [gs]etting
  rocker: pass "learning" value as a parameter to
    rocker_port_set_learning
  rocker: pre-allocate wait structures during cmd ring init
  rocker: remove trans parameter to rocker_cmd_exec function
  rocker: call rocker_cmd_exec function with "nowait" boolean instead of
    flags
  rocker: move OF-DPA stuff into separate file

 drivers/net/ethernet/rocker/Makefile       |    1 +
 drivers/net/ethernet/rocker/rocker.c       | 5478 ----------------------------
 drivers/net/ethernet/rocker/rocker.h       |  543 +--
 drivers/net/ethernet/rocker/rocker_hw.h    |  467 +++
 drivers/net/ethernet/rocker/rocker_main.c  | 3093 ++++++++++++++++
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 2927 +++++++++++++++
 drivers/net/ethernet/rocker/rocker_tlv.c   |   54 +
 drivers/net/ethernet/rocker/rocker_tlv.h   |  202 +
 include/uapi/linux/if_link.h               |   11 +
 9 files changed, 6847 insertions(+), 5929 deletions(-)
 delete mode 100644 drivers/net/ethernet/rocker/rocker.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_hw.h
 create mode 100644 drivers/net/ethernet/rocker/rocker_main.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_ofdpa.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_tlv.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_tlv.h

-- 
1.9.3
