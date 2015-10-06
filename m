From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 00/14] rocker: add support for multiple worlds
Date: Tue,  6 Oct 2015 10:01:09 +0200
Message-ID: <1444118483-10547-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34419 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbJFIB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 04:01:26 -0400
Received: by wicfx3 with SMTP id fx3so153632540wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 01:01:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset allows new rocker worlds to be easily added in future (like eBPF
based one I have been working on). The main part of the patchset is the OF-DPA
carve-out. It resuts in OF-DPA specific file. Clean cut.

patches added/removed:
v1->v2:
 - rtnl rocker mode change userspace expose patch was removed
v2->v3:
 - added the last patch (handling undefined world ops)

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
  rocker: pass "learning" value as a parameter to
    rocker_port_set_learning
  rocker: pre-allocate wait structures during cmd ring init
  rocker: remove trans parameter to rocker_cmd_exec function
  rocker: call rocker_cmd_exec function with "nowait" boolean instead of
    flags
  rocker: move OF-DPA stuff into separate file
  rocker: return -EOPNOTSUPP for undefined world ops

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
