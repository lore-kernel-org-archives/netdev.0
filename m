From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 00/13] rocker: add support for multiple worlds
Date: Mon,  5 Oct 2015 19:43:53 +0200
Message-ID: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36232 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbbJERoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:08 -0400
Received: by wicgb1 with SMTP id gb1so130420927wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset allows new rocker worlds to be easily added in future (like eBPF
based one I have been working on). The main part of the patchset is the OF-DPA
carve-out. It resuts in OF-DPA specific file. Clean cut.

v1->v2:
 - rtnl rocker mode change userspace expose patch was removed

Jiri Pirko (13):
  rocker: remove unused rocker_port param from alloc funcs and shorten
    their names
  rocker: rename rocker.h to rocker_hw.h
  rocker: rename rocker.c to rocker_main.c
  rocker: push tlv processing into separate files
  rocker: implement set settings mode command
  rocker: introduce worlds infrastructure
  rocker: introduce OF-DPA world skeleton
  rocker: set default world on port probe and clean world on remove
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
 drivers/net/ethernet/rocker/rocker_main.c  | 2993 +++++++++++++++
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 2927 +++++++++++++++
 drivers/net/ethernet/rocker/rocker_tlv.c   |   54 +
 drivers/net/ethernet/rocker/rocker_tlv.h   |  202 +
 8 files changed, 6736 insertions(+), 5929 deletions(-)
 delete mode 100644 drivers/net/ethernet/rocker/rocker.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_hw.h
 create mode 100644 drivers/net/ethernet/rocker/rocker_main.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_ofdpa.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_tlv.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_tlv.h

-- 
1.9.3
